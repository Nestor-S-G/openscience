
#Set the risk parameters----
lambda=1
alpha=1
beta_logit=40
N_ID=dim(Sequence_bank)[1]
N_trial=dim(Sequence_bank)[2]

logit=function(V,beta_logit){#return the betting rate for a given value of betting
  C=exp(beta_logit*V)/(1+exp(beta_logit*V))
  return(C)
}
#Simulate the choices of rational agents----
Choice_rational=matrix(0,198,630)
outcome_rational=matrix(0,198,630)
Bet_prob_rational=matrix(0,198,630)
for(ID in 1:N_ID){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
    Bet_prob_rational[ID,t]=logit(V,beta_logit)
    Choice_rational[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_rational[ID,t], Bet_prob_rational[ID,t]))
    if(Choice_rational[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome_rational[ID,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome_rational[ID,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

#Simulate the choices of CbD agents----
Choice_CbD=matrix(0,198,630)
outcome_CbD=matrix(0,198,630)
Bet_prob_CbD=matrix(0,198,630)
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
for(ID in 1:N_ID){
  G=0
  kappa1=rtruncnorm(1, a=0, b=0.3, mean = 0.18, sd = 0.05)
  kappa2=rtruncnorm(1, a=0.7, b=0.9, mean = 0.8, sd = 0.05)
  theta=rtruncnorm(1, a=0.9, b=1, mean = 0.95, sd = 0.05)
  for(t in 1:N_trial){
    if(t>2 && Sequence_bank[ID,t,3]>Sequence_bank[ID,t-1,3]) {G=0}#Reset the influence in each sequence
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
    Bet_prob_CbD[ID,t]=(1-DA)*Bet_prob_rational[ID,t]+DA
    Choice_CbD[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_CbD[ID,t], Bet_prob_CbD[ID,t]))
    if(Choice_CbD[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome_CbD[ID,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome_CbD[ID,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
    G=G*theta+I(outcome_CbD[ID,t]>0)
  }
}






#Simulate the choices of RL agents----
beta_logit=30
Choice_RL=matrix(0,198,630)
outcome_RL=matrix(0,198,630)
Bet_prob_RL=matrix(0,198,630)
eta=0.5
for(ID in 1:N_ID){
  sequence=1
  #Q_RL=runif(1,-0.7,1.3)
  for(t in 1:N_trial){
    if(sequence<ceiling(t/105) || t==1){#reset the Q-value for a new sequence
      Q_RL=runif(1,-0.7,1.3)#The Q value of bet, the Q-value of skip is always 0
      sequence=ceiling(t/105)
    }
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    Bet_prob_RL[ID,t]=logit(Q_RL,beta_logit)
    Choice_RL[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_RL[ID,t], Bet_prob_RL[ID,t]))
    if(Choice_RL[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome_RL[ID,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome_RL[ID,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
      Q_RL=(1-eta)*Q_RL+eta*outcome_RL[ID,t]
    }
  }
}

#Choices to be fitted----
Choice_fit=Choice_CbD
outcome_fit=outcome_CbD

#Choice_fit=Sequence_bank[,,7]
#outcome_fit=Sequence_bank[,,8]

#Choice_fit=Choice_RL
#outcome_fit=outcome_RL

#Choice_fit=Choice_rational
#outcome_fit=outcome_rational

Bet_yellow_fit=rep(0,N_ID)
Bet_blue_fit=rep(0,N_ID)
for(ID in 1:N_ID){
  Stats_ID=Sequence_bank[ID,,]
  Yellow=Choice_fit[ID,][Stats_ID[,4]==0.2]
  Blue=Choice_fit[ID,][Stats_ID[,4]==0.8]
  Bet_yellow_fit[ID]=sum(Yellow==1)/sum(Yellow<2)
  Bet_blue_fit[ID]=sum(Blue==1)/sum(Blue<2)
}

#The training dataset is sequences 1,3,5; and the testing dataset is sequences 2,4,6
Train_trials=c(1:105,211:315,421:525)
Test_trials=c(106:210, 316:420, 526:630)
#Fit the rational model-----
Param_rational=matrix(0,N_ID,3)#beta_logit, alpha, lambda for each participant
OOS_rational=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_rational=function(Param_agent,Stats_agent){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  for(t in 1:N_trial){
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
    Bet_prob_agent[t]=logit(V,beta_logit)
    if(Stats_agent[t,7] != 2){#Exclude the missing trials
      if(Stats_agent[t,7] == 1){#bet
        logl[t]=max(log(Bet_prob_agent[t]),-30)
      } else{#pass
        logl[t]=max(log(1-Bet_prob_agent[t]),-30)
      }
    }
  }
  return(-sum(logl))
}

for(ID in 1:N_ID){
  range_low_rational=c(40,0.7,1)
  range_high_rational=c(60,1,2.5)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  Param_rational[ID,]=optim(c(40,1,1),Likelihood_rational,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_rational,upper=range_high_rational)$par
  OOS_rational[ID]=Likelihood_rational(Param_rational[ID,],Stats_agent_test)
}


#Fit the rational model with loss tolerance-----
Param_rational_tolerance=matrix(0,N_ID,3)#beta_logit, alpha, lambda for each participant
OOS_rational_tolerance=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_rational=function(Param_agent,Stats_agent){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  for(t in 1:N_trial){
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
    Bet_prob_agent[t]=logit(V,beta_logit)
    if(Stats_agent[t,7] != 2){#Exclude the missing trials
      if(Stats_agent[t,7] == 1){#bet
        logl[t]=max(log(Bet_prob_agent[t]),-30)
      } else{#pass
        logl[t]=max(log(1-Bet_prob_agent[t]),-30)
      }
    }
  }
  return(-sum(logl))
}

Index=which(Bet_yellow_fit>0.01)
for(ID in Index){
  range_low_rational=c(40,0.7,0.5)
  range_high_rational=c(60,1.5,2.5)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  Param_rational_tolerance[ID,]=optim(c(40,1,1),Likelihood_rational,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_rational,upper=range_high_rational)$par
  OOS_rational_tolerance[ID]=Likelihood_rational(Param_rational_tolerance[ID,],Stats_agent_test)
}



#Fit the CbD Model with entropy uncertainty----
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
Param_CbD=matrix(0,N_ID,6)#beta_logit, alpha, lambda, C_kappa1, kappa2, theta, for each participant
OOS_CbD=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_CbD=function(Param_agent,Stats_agent,Train){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  C_kappa1=Param_agent[4]
  kappa2=Param_agent[5]
  theta=Param_agent[6]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  G=0
  for(t in 1:N_trial){
    if(t>2 && Stats_agent[t,3]!=Stats_agent[t-1,3]) {G=0}#Reset the influence in each sequence
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    kappa1=ifelse(uncertainty==1,C_kappa1*entropy_low,C_kappa1*entropy_high)#Kappa1 is decided by the baseline value and the entropy
    DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
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
  range_low_CbD=c(40,0.7,1,0,0.5,0.9)
  range_high_CbD=c(60,1,2.5,0.4,1,1)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  if(Bet_yellow_fit[ID]>0.01){
    initial_CbD=c(40,1,1,0.2,0.7,0.95)
  } else{
    initial_CbD=c(40,1,1,0,0.7,0.95)
  }
  result=optim_wrapper(initial_CbD,Likelihood_CbD,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_CbD,upper=range_high_CbD)
  # Check if optimization was successful
  if (!is.null(result)) {
    Param_CbD[ID,]<- result$par
    OOS_CbD[ID]=Likelihood_CbD(Param_CbD[ID,],Stats_agent_test)
  } else {
    Param_CbD[ID,] <- NA  # Set to NA or handle as needed
    OOS_CbD[ID,] <- NA
    Error_seed=c(Error_seed,i)
    print(i)
  }
}






#Fit the CbD Model with no uncertainty----
Param_CbD_no_uncertain=matrix(0,N_ID,6)#beta_logit, alpha, lambda, Kappa1, kappa2, theta, for each participant
OOS_CbD_no_uncertain=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_CbD=function(Param_agent,Stats_agent,Train){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  kappa1=Param_agent[4]
  kappa2=Param_agent[5]
  theta=Param_agent[6]
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
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
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
  range_low_CbD=c(40,0.7,1,0,0.5,0.9)
  range_high_CbD=c(60,1,2.5,0.4,1,1)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  if(Bet_yellow_fit[ID]>0){
    initial_CbD=c(40,1,1,0.2,0.7,0.95)
  } else{
    initial_CbD=c(40,1,1,0,0.7,0.95)
  }
  result=optim_wrapper(initial_CbD,Likelihood_CbD,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_CbD,upper=range_high_CbD)
  # Check if optimization was successful
  if (!is.null(result)) {
    Param_CbD_no_uncertain[ID,]<- result$par
    OOS_CbD_no_uncertain[ID]=Likelihood_CbD(Param_CbD_no_uncertain[ID,],Stats_agent_test)
  } else {
    Param_CbD_no_uncertain[ID,] <- NA  # Set to NA or handle as needed
    OOS_CbD_no_uncertain[ID,] <- NA
    Error_seed=c(Error_seed,i)
    print(i)
  }
}





#Fit the CbD Model with no uncertainty and loss tolerance----
Param_CbD_no_uncertain_tolerance=matrix(0,N_ID,6)#beta_logit, alpha, lambda, Kappa1, kappa2, theta, for each participant
OOS_CbD_no_uncertain_tolerance=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_CbD=function(Param_agent,Stats_agent,Train){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  kappa1=Param_agent[4]
  kappa2=Param_agent[5]
  theta=Param_agent[6]
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
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
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
  range_low_CbD=c(40,0.7,0.5,0,0.5,0.9)
  range_high_CbD=c(60,1.5,2.5,0.4,1,1)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  if(Bet_yellow_fit[ID]>0.01){
    initial_CbD=c(40,1,1,0.2,0.7,0.95)
  } else{
    initial_CbD=c(40,1,1,0,0.7,0.95)
  }
  result=optim_wrapper(initial_CbD,Likelihood_CbD,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_CbD,upper=range_high_CbD)
  # Check if optimization was successful
  if (!is.null(result)) {
    Param_CbD_no_uncertain_tolerance[ID,]<- result$par
    OOS_CbD_no_uncertain_tolerance[ID]=Likelihood_CbD(Param_CbD_no_uncertain_tolerance[ID,],Stats_agent_test)
  } else {
    Param_CbD_no_uncertain_tolerance[ID,] <- NA  # Set to NA or handle as needed
    OOS_CbD_no_uncertain_tolerance[ID,] <- NA
    Error_seed=c(Error_seed,i)
    print(i)
  }
}








#Fit the CbD Model with two kappa1----
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
Param_CbD_two=matrix(0,N_ID,7)#beta_logit, alpha, lambda, High_kappa1,Low_kappa1, kappa2, theta, for each participant
OOS_CbD_two=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_CbD=function(Param_agent,Stats_agent,Train){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  alpha=Param_agent[2]
  lambda=Param_agent[3]
  High_kappa1=Param_agent[4]
  Low_kappa1=Param_agent[5]
  kappa2=Param_agent[6]
  theta=Param_agent[7]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  G=0
  for(t in 1:N_trial){
    if(t>2 && Stats_agent[t,3]!=Stats_agent[t-1,3]) {G=0}#Reset the influence in each sequence
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    kappa1=ifelse(uncertainty==1,Low_kappa1,High_kappa1)#Kappa1 is decided by the baseline value and the entropy
    DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
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
  range_low_CbD=c(40,0.7,1,0,0,0.5,0.9)
  range_high_CbD=c(60,1,2.5,0.4,0.4,1,1)
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  if(Bet_yellow_fit[ID]>0.01){
    initial_CbD=c(40,1,1,0.2,0.2,0.7,0.95)
  } else{
    initial_CbD=c(40,1,1,0,0,0.7,0.95)
  }
  result=optim_wrapper(initial_CbD,Likelihood_CbD,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_CbD,upper=range_high_CbD)
  # Check if optimization was successful
  if (!is.null(result)) {
    Param_CbD_two[ID,]<- result$par
    OOS_CbD_two[ID]=Likelihood_CbD(Param_CbD_two[ID,],Stats_agent_test)
  } else {
    Param_CbD_two[ID,] <- NA  # Set to NA or handle as needed
    OOS_CbD_two[ID,] <- NA
    Error_seed=c(Error_seed,i)
    print(i)
  }
}




#Fit the RL model with initial Q as free values-----
Param_RL=matrix(0,N_ID,5)#beta_logit, eta, the 3 Q values for the 2 training sequences, and undirectional exploration
OOS_RL=rep(0,N_ID)#OOS goodness-of-fit for each agent
Likelihood_RL=function(Param_agent,Stats_agent){#Stats_agent is the supercut matrix from Sequence_bank for that agent, with the 7th and 8th columns replaced if needed
  beta_logit=Param_agent[1]
  eta=Param_agent[2]
  Q_initial=Param_agent[3:5]
  N_trial=dim(Stats_agent)[1]
  Bet_prob_agent=rep(0,N_trial)
  logl=rep(0,N_trial)
  #Q_RL=runif(1,-0.7,1.3)
  for(t in 1:N_trial){
    seq=0
    if(Stats_agent[t,3]!=Stats_agent[t-1,3] || t==1){#reset the Q-value for a new sequence
      seq=seq+1
      Q_RL=Q_initial[seq]
      Q_skip=0
    }
    prob_win=Stats_agent[t,4]
    uncertainty=Stats_agent[t,5]
    reward=Stats_agent[t,6]
    Bet_prob_agent[t]=exp(beta_logit*Q_RL)/(exp(beta_logit*Q_RL)+exp(beta_logit*Q_skip))
    if(Stats_agent[t,7] != 2){#Exclude the missing trials
      if(Stats_agent[t,7] == 1){#bet
        logl[t]=max(log(Bet_prob_agent[t]),-30)
        Q_RL=(1-eta)*Q_RL+eta*Stats_agent[t,8]
        Q_skip=Q_skip
      } else{#pass
        logl[t]=max(log(1-Bet_prob_agent[t]),-30)
        Q_skip=(1-eta)*Q_skip
        Q_RL=Q_RL
      }
    }
  }
  return(-sum(logl))
}

Index=which(Bet_yellow_fit>0.01)
for(ID in Index){
  range_low_RL=c(40,0.1,rep(-0.7,3))
  range_high_RL=c(60,1,rep(1.3,3))
  Stats_agent=Sequence_bank[ID,,]
  Stats_agent[,7]=Choice_fit[ID,]
  Stats_agent[,8]=outcome_fit[ID,]
  Stats_agent_train=Stats_agent[Train_trials,]
  Stats_agent_test=Stats_agent[Test_trials,]
  Param_RL[ID,]=optim(c(40,0.5,rep(0,3)),Likelihood_RL,Stats_agent=Stats_agent_train, method="L-BFGS-B",lower=range_low_RL,upper=range_high_RL)$par
  Param_RL_test=c(Param_RL[ID,1:2],runif(3,-0.7,1.3))
  OOS_RL[ID]=Likelihood_RL(Param_RL[ID,],Stats_agent_test)
}







#save.image("Model Recovery with simulated CbD agents and no uncertainty effect_low trembling_40to60.RData")