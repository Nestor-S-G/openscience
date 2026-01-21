
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

control=1:99
test=100:198

high_uncerainty_yellow_index=(Sequence_bank[,,5]==0.5 & Sequence_bank[,,4]==0.2)
low_uncerainty_yellow_index=(Sequence_bank[,,5]==1 & Sequence_bank[,,4]==0.2)


table_4=matrix(0,4,2)
rownames(table_4)=c("Base","Fixed-kappa1 Pavlovian", "Enchaned Pavlovian", "Lab Data")
colnames(table_4)=c("Low-uncertainty", "High-uncertainty")


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

table_4[1,]=c(
  mean(Choice_rational[low_uncerainty_yellow_index]),
  mean(Choice_rational[high_uncerainty_yellow_index])
)


#Simulate the choices of CbD agents with uncertainty effect----
#library(truncnorm)
Choice_CbD=matrix(0,198,630)
Bet_prob_CbD=matrix(0,198,630)
entropy_high=-1*(0.1*log(0.1)+0.4*log(0.4)+0.5*log(0.5))
entropy_low=-1*(0.2*log(0.2)+0.8*log(0.8))
for(ID in 1:N_ID){
  G=0
  C_kappa1=rtruncnorm(1, a=0.05, b=0.3, mean = 0.12, sd = 0.05)
  kappa2=rtruncnorm(1, a=0.6, b=0.8, mean = 0.7, sd = 0.05)
  theta=rtruncnorm(1, a=0.9, b=1, mean = 0.95, sd = 0.05) #uncertainty effect
  # C_kappa1=rtruncnorm(1, a=0.05, b=0.3, mean = 0.12, sd = 0.05)
  # kappa2=rtruncnorm(1, a=0.6, b=0.8, mean = 0.7, sd = 0.05)
  # theta=rtruncnorm(1, a=0.9, b=1, mean = 0.95, sd = 0.05)
  for(t in 1:N_trial){
    if(t>2 && Sequence_bank[ID,t,3]>Sequence_bank[ID,t-1,3]) {G=0}#Reset the influence in each sequence
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    #kappa1=ifelse(uncertainty==1,C_kappa1*entropy_low,C_kappa1*entropy_high)#Kappa1 is decided by the baseline value and the entropy
    kappa1=ifelse(uncertainty==1,C_kappa1*entropy_low,C_kappa1*entropy_high)
    DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
    Bet_prob_CbD[ID,t]=(1-DA)*Bet_prob_rational[ID,t]+DA
    Choice_CbD[ID,t]=sample(c(0, 1), size = 1, prob = c(1-Bet_prob_CbD[ID,t], Bet_prob_CbD[ID,t]))
    outcome=0
    if(Choice_CbD[ID,t]==1){#The corresponding outcome
      if(uncertainty==1){
        outcome=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        outcome=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
    G=G*theta+I(outcome>0)
  }
}

table_4[3,]=c(
  mean(Choice_CbD[low_uncerainty_yellow_index]),
  mean(Choice_CbD[high_uncerainty_yellow_index])
)


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

table_4[2,]=c(
  mean(Choice_CbD[low_uncerainty_yellow_index]),
  mean(Choice_CbD[high_uncerainty_yellow_index])
)

Choice_lab=Sequence_bank[,,7]
table_4[4,]=c(
  mean(Choice_lab[low_uncerainty_yellow_index]),
  mean(Choice_lab[high_uncerainty_yellow_index])
)
