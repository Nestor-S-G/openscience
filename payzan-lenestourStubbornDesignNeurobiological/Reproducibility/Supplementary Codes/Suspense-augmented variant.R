
load("Model comparison with the lab data_beta40to60_exploration and loss tolerance.RData")
#Fit the suspense CbD Model with no uncertainty----
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
Param_CbD_suspense_no_uncertain=matrix(0,N_ID,7)#beta_logit, alpha, lambda, Kappa1, kappa2, theta, suspense-related-arousal for each participant
OOS_CbD_suspense_no_uncertain=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_CbD=function(Param_agent,Stats_agent,Train){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  kappa1=Param_agent[4]
  kappa2=Param_agent[5]
  theta=Param_agent[6]
  SRA=Param_agent[7]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  G=0
  for(t in 1:N_trial){
    if(t>2 && Stats_agent[t,3]!=Stats_agent[t-1,3]) {G=0}#Reset the influence in each sequence
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
    entropy=ifelse(uncertainty==1,entropy_low,entropy_high)
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)+SRA*entropy
    Bet_prob_base=logit(V,beta_logit)
    Bet_prob_agent[t]=(1-DA)*Bet_prob_base+DA
    if(Stats_agent[t,7] != 2){#Exclude the missing trials
      if(Stats_agent[t,7] == 1){#bet
        logl[t]=max(log(Bet_prob_agent[t]),-50)
      } else{#pass
        logl[t]=max(log(1-Bet_prob_agent[t]),-50)
      }
    }
    G=G*theta+I(Stats_agent[t,8]>0)#There will be outcome 0 for missed trials, so the G simply decay
  }
  return(-sum(logl))
}

# Set optimization parameters
control <- list(maxit = 10000)  # Maximum number of iterations

# Set the time limit (in seconds) for the optimization
time_limit <- 300  # 5 minutes


optim_wrapper <- function(par, fn, ...) {
  # Start the timer
  start_time <- Sys.time()
  
  # Perform optimization
  result <- tryCatch({
    optim(par = par, fn = fn, ..., control = control)
  }, error = function(e) e)
  
  # Check if the time limit has been reached
  elapsed_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  if (elapsed_time > time_limit) {
    warning("Optimization exceeded time limit")
    result <- NULL
  }
  
  return(result)
}

Error_seed=NULL

Index=which(Bet_yellow_fit>0.01)
for(ID in Index){
  range_low_CbD=c(40,0.7,1,0,0.5,0.9,0)
  range_high_CbD=c(60,1,2.5,0.4,1,1,1)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  if(Bet_yellow_fit[ID]>0){
    initial_CbD=c(40,1,1,0,0.7,0.95,0.2)
  } else{
    initial_CbD=c(40,1,1,0,0.7,0.95,0)
  }
  result=optim_wrapper(initial_CbD,Likelihood_CbD,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_CbD,upper=range_high_CbD)
  # Check if optimization was successful
  if (!is.null(result)) {
    Param_CbD_suspense_no_uncertain[ID,]<- result$par
    OOS_CbD_suspense_no_uncertain[ID]=Likelihood_CbD(Param_CbD_suspense_no_uncertain[ID,],Stats_agent_test)
  } else {
    Param_CbD_suspense_no_uncertain[ID,] <- NA  # Set to NA or handle as needed
    OOS_CbD_suspense_no_uncertain[ID,] <- NA
    Error_seed=c(Error_seed,i)
    print(i)
  }
}



