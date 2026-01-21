#rm(list=ls())
#Set the current path and Load the data bank----
load("Data Bank.RData")
#Sequence_Bank contains the sequences for all participants, with dimention (198,630,6)
#The first dimension represents 198 participants, here we exclude ID18 because the data is partly missing
#The first 99 elements are control, and the last 99 are test
#The names of the first dimension tell their ID, and the variable ID_sequence also gives the ID of the participant
#The second dimension records the trials
#The third dimension records the "round", "block", "sequence", "winning prob", "uncertainty", "reward size", "choice", "outcome"; see dimension names.

#Set the risk parameters----
lambda=1
alpha=1
beta_logit=40
N_ID=dim(Sequence_bank)[1]
N_trial=dim(Sequence_bank)[2]

logit=function(V){#return the betting rate for a given value of betting
  C=exp(beta_logit*V)/(1+exp(beta_logit*V))
  return(C)
}

#Simulate the choices of rational agents----
Choice_rational=matrix(0,198,630)
Bet_prob_rational=matrix(0,198,630)
for(ID in 1:N_ID){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
    Bet_prob_rational[ID,t]=logit(V)
    Choice_rational[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_rational[ID,t], Bet_prob_rational[ID,t]))
  }
}



#Simulate the choices of CbD agents with no uncertainty effect----
Choice_CbD=matrix(0,198,630)
outcome_CbD=matrix(0,198,630)
Bet_prob_CbD=matrix(0,198,630)
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
control=1:99
test=100:198

for(ID in 1:N_ID){
  G=0
  kappa1=rtruncnorm(1, a=0, b=0.3, mean = 0.15, sd = 0.05)
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

#Simulate the choices of RL (Type 1) agents----
beta_logit=30
Choice_RL_1=matrix(0,198,630)
Bet_prob_RL=matrix(0,198,630)
eta=0.05
U_RL=0 #Undirectional exploration
for(ID in 1:N_ID){
  sequence=1
  #Q_RL=runif(1,-0.7,1.3)
  for(t in 1:N_trial){
    if(sequence<ceiling(t/105) || t==1){#reset the Q-value for a new sequence
      Q_RL=0.5
      #Q_RL=runif(1,-0.7,1.3)#The Q value of bet, the Q-value of skip is always 0
      sequence=ceiling(t/105)
      Q_skip=0
    }
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    Bet_prob_RL[ID,t]=exp(beta_logit*Q_RL)/(exp(beta_logit*Q_RL)+exp(beta_logit*Q_skip))
    Choice_RL_1[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_RL[ID,t], Bet_prob_RL[ID,t]))
    if(Choice_RL_1[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
      Q_RL=(1-eta)*Q_RL+eta*outcome
      Q_skip=Q_skip+U_RL
    } else{#skip
      Q_skip=(1-eta)*Q_skip
      Q_RL=Q_RL+U_RL
    }
  }
}

#Simulate the choices of RL (Type 2) agents----
beta_logit=30
Choice_RL_2=matrix(0,198,630)
Bet_prob_RL=matrix(0,198,630)
eta=0.4
U_RL=0 #Undirectional exploration
for(ID in 1:N_ID){
  sequence=1
  #Q_RL=runif(1,-0.7,1.3)
  for(t in 1:N_trial){
    if(sequence<ceiling(t/105) || t==1){#reset the Q-value for a new sequence
      Q_RL=0.5
      #Q_RL=runif(1,-0.7,1.3)#The Q value of bet, the Q-value of skip is always 0
      sequence=ceiling(t/105)
      Q_skip=0
    }
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    Bet_prob_RL[ID,t]=exp(beta_logit*Q_RL)/(exp(beta_logit*Q_RL)+exp(beta_logit*Q_skip))
    Choice_RL_2[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_RL[ID,t], Bet_prob_RL[ID,t]))
    if(Choice_RL_2[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
      Q_RL=(1-eta)*Q_RL+eta*outcome
      Q_skip=Q_skip+U_RL
    } else{#skip
      Q_skip=(1-eta)*Q_skip
      Q_RL=Q_RL+U_RL
    }
  }
}

#Table 3----------
control=1:99
test=100:198
control_blue_index=(Sequence_bank[control,,4]==0.8)
control_yellow_index=(Sequence_bank[control,,4]==0.2)
test_blue_index=(Sequence_bank[test,,4]==0.8)
test_yellow_index=(Sequence_bank[test,,4]==0.2)

table_3=matrix(0,5,4)
rownames(table_3)=c("RL (Type 1)", "RL (Type 2)", "Base", "Pavlovian-augmented", "Lab Data")
colnames(table_3)=c("Blue, Control", "Blue, Test", "Yellow, Control", "Yellow, Test")
table_3[1,]=c(mean(Choice_RL_1[control,][control_blue_index]), 
              mean(Choice_RL_1[test,][test_blue_index]),
              mean(Choice_RL_1[control,][control_yellow_index]),
              mean(Choice_RL_1[test,][test_yellow_index]))

table_3[2,]=c(mean(Choice_RL_2[control,][control_blue_index]), 
              mean(Choice_RL_2[test,][test_blue_index]),
              mean(Choice_RL_2[control,][control_yellow_index]),
              mean(Choice_RL_2[test,][test_yellow_index]))

table_3[3,]=c(mean(Choice_rational[control,][control_blue_index]), 
              mean(Choice_rational[test,][test_blue_index]),
              mean(Choice_rational[control,][control_yellow_index]),
              mean(Choice_rational[test,][test_yellow_index]))

table_3[4,]=c(mean(Choice_CbD[control,][control_blue_index]), 
              mean(Choice_CbD[test,][test_blue_index]),
              mean(Choice_CbD[control,][control_yellow_index]),
              mean(Choice_CbD[test,][test_yellow_index]))

Choice_lab=Sequence_bank[,,7]

table_3[5,]=c(mean(Choice_lab[control,][control_blue_index]), 
              mean(Choice_lab[test,][test_blue_index]),
              mean(Choice_lab[control,][control_yellow_index]),
              mean(Choice_lab[test,][test_yellow_index]))


#Extended version of Table 3----
table_3_extend=matrix(0,8,4)
rownames(table_3_extend)=c("RL (Type 1)", "RL (Type 2)", "RL (Type 2)+ UE", "Base (RN)", "Pavlovian-augmented (RN)", "Base (LT)", "Pavlovian-augmented (LT)","Lab Data")
colnames(table_3_extend)=c("Blue, Control", "Blue, Test", "Yellow, Control", "Yellow, Test")
table_3_extend[c(1,2,4,5,8),]=table_3[1:5,]

#Simulate the choices of RL (Type 2) agents+ UE----
beta_logit=30
Choice_RL_2=matrix(0,198,630)
Bet_prob_RL=matrix(0,198,630)
eta=0.4
U_RL=0.5 #Undirectional exploration
for(ID in 1:N_ID){
  sequence=1
  #Q_RL=runif(1,-0.7,1.3)
  for(t in 1:N_trial){
    if(sequence<ceiling(t/105) || t==1){#reset the Q-value for a new sequence
      Q_RL=0.5
      #Q_RL=runif(1,-0.7,1.3)#The Q value of bet, the Q-value of skip is always 0
      sequence=ceiling(t/105)
      Q_skip=0
    }
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    Bet_prob_RL[ID,t]=exp(beta_logit*Q_RL)/(exp(beta_logit*Q_RL)+exp(beta_logit*Q_skip))
    Choice_RL_2[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_RL[ID,t], Bet_prob_RL[ID,t]))
    if(Choice_RL_2[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
      Q_RL=(1-eta)*Q_RL+eta*outcome
      Q_skip=Q_skip+U_RL
    } else{#skip
      Q_skip=(1-eta)*Q_skip
      Q_RL=Q_RL+U_RL
    }
  }
}

table_3_extend[3,]=c(mean(Choice_RL_2[control,][control_blue_index]), 
              mean(Choice_RL_2[test,][test_blue_index]),
              mean(Choice_RL_2[control,][control_yellow_index]),
              mean(Choice_RL_2[test,][test_yellow_index]))
#Set the loss aversion----
lambda=0.6
alpha=1
beta_logit=40
N_ID=dim(Sequence_bank)[1]
N_trial=dim(Sequence_bank)[2]

logit=function(V){#return the betting rate for a given value of betting
  C=exp(beta_logit*V)/(1+exp(beta_logit*V))
  return(C)
}

#Simulate the choices of rational agents----
Choice_rational=matrix(0,198,630)
Bet_prob_rational=matrix(0,198,630)
for(ID in 1:N_ID){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    V=uncertainty*(prob_win*(reward-0.7)^alpha-lambda*(1-prob_win)*0.7^alpha)
    Bet_prob_rational[ID,t]=logit(V)
    Choice_rational[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_rational[ID,t], Bet_prob_rational[ID,t]))
  }
}



#Simulate the choices of CbD agents with no uncertainty effect----
Choice_CbD=matrix(0,198,630)
outcome_CbD=matrix(0,198,630)
Bet_prob_CbD=matrix(0,198,630)
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
control=1:99
test=100:198

for(ID in 1:N_ID){
  G=0
  kappa1=rtruncnorm(1, a=0, b=0.3, mean = 0.15, sd = 0.05)
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

table_3_extend[6,]=c(mean(Choice_rational[control,][control_blue_index]), 
                     mean(Choice_rational[test,][test_blue_index]),
                     mean(Choice_rational[control,][control_yellow_index]),
                     mean(Choice_rational[test,][test_yellow_index]))

table_3_extend[7,]=c(mean(Choice_CbD[control,][control_blue_index]), 
                     mean(Choice_CbD[test,][test_blue_index]),
                     mean(Choice_CbD[control,][control_yellow_index]),
                     mean(Choice_CbD[test,][test_yellow_index]))
