
ID=150
N=1000

#Simulate the outcome of the different agents-----
earning_optimal=matrix(0,N,N_trial)
earning_75=matrix(0,N,N_trial)
earning_25=matrix(0,N,N_trial)
earning_50=matrix(0,N,N_trial)
for(i in 1:N){
    for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    n_yellow=sum(Sequence_bank[ID,,4]==0.2)
    if(prob_win==0.8){
      choice=1
    } else{
      choice=0
      #choice_10=sample(c(0, 1), size = 1, prob = c(0.9,0.1))
    }
    if(choice==1){
      if(uncertainty==1){
        earning_optimal[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_optimal[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

for(i in 1:N){
  n_yellow=sum(Sequence_bank[ID,,4]==0.2)
  n_bet_yellow=n_yellow*0.75
  index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      choice=1
    } else if (t %in% index_choice_yellow){
      choice=1
    }
    if(choice==1){
      if(uncertainty==1){
        earning_75[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_75[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

for(i in 1:N){
  n_yellow=sum(Sequence_bank[ID,,4]==0.2)
  n_bet_yellow=n_yellow*0.25
  index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      choice=1
    } else if (t %in% index_choice_yellow){
      choice=1
    }
    if(choice==1){
      if(uncertainty==1){
        earning_25[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_25[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

for(i in 1:N){
  n_yellow=sum(Sequence_bank[ID,,4]==0.2)
  n_bet_yellow=n_yellow*0.5
  index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      choice=1
    } else if (t %in% index_choice_yellow){
      choice=1
    }
    if(choice==1){
      if(uncertainty==1){
        earning_50[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_50[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

#Simulate the outcome of the different agents with fixed blue outcomes-----
earning_optimal=matrix(0,N,N_trial)
earning_75=matrix(0,N,N_trial)
earning_25=matrix(0,N,N_trial)
earning_50=matrix(0,N,N_trial)

n_blue=sum(Sequence_bank[ID,,4]==0.8)
Win_blue=sample(which(Sequence_bank[ID,,4]==0.8), n_blue*0.8, replace = FALSE)

for(i in 1:N){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    n_yellow=sum(Sequence_bank[ID,,4]==0.2)
    if(prob_win==0.8){
      if(t %in% Win_blue){
        if(uncertainty==1){
        earning_optimal[i,t]=reward-0.7
        } else{
          earning_optimal[i,t]=sample(c(reward-0.7,0),1,prob=c(0.5,0.5))
        }
      } else{
        if(uncertainty==1){
          earning_optimal[i,t]=-0.7
        } else{
          earning_optimal[i,t]=sample(c(-0.7,0),1,prob=c(0.5,0.5))
        }
      }
    }
  }
}

n_yellow=sum(Sequence_bank[ID,,4]==0.2)
n_bet_yellow=n_yellow*0.75
index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
for(i in 1:N){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      if(t %in% Win_blue){
        if(uncertainty==1){
          earning_75[i,t]=reward-0.7
        } else{
          earning_75[i,t]=sample(c(reward-0.7,0),1,prob=c(0.5,0.5))
        }
      } else{
        if(uncertainty==1){
          earning_75[i,t]=-0.7
        } else{
          earning_75[i,t]=sample(c(-0.7,0),1,prob=c(0.5,0.5))
        }
      }
    } else if (t %in% index_choice_yellow){
      if(uncertainty==1){
        earning_75[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_75[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}

n_yellow=sum(Sequence_bank[ID,,4]==0.2)
n_bet_yellow=n_yellow*0.25
index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
for(i in 1:N){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      if(t %in% Win_blue){
        if(uncertainty==1){
          earning_25[i,t]=reward-0.7
        } else{
          earning_25[i,t]=sample(c(reward-0.7,0),1,prob=c(0.5,0.5))
        }
      } else{
        if(uncertainty==1){
          earning_25[i,t]=-0.7
        } else{
          earning_25[i,t]=sample(c(-0.7,0),1,prob=c(0.5,0.5))
        }
      }
    } else if (t %in% index_choice_yellow){
      if(uncertainty==1){
        earning_25[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_25[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}


n_yellow=sum(Sequence_bank[ID,,4]==0.2)
n_bet_yellow=n_yellow*0.5
index_choice_yellow=sample(which(Sequence_bank[ID,,4]==0.2),n_bet_yellow, replace = FALSE)
for(i in 1:N){
  for(t in 1:N_trial){
    prob_win=Sequence_bank[ID,t,4]
    uncertainty=Sequence_bank[ID,t,5]
    reward=Sequence_bank[ID,t,6]
    choice=0
    if(prob_win==0.8){
      if(t %in% Win_blue){
        if(uncertainty==1){
          earning_50[i,t]=reward-0.7
        } else{
          earning_50[i,t]=sample(c(reward-0.7,0),1,prob=c(0.5,0.5))
        }
      } else{
        if(uncertainty==1){
          earning_50[i,t]=-0.7
        } else{
          earning_50[i,t]=sample(c(-0.7,0),1,prob=c(0.5,0.5))
        }
      }
    } else if (t %in% index_choice_yellow){
      if(uncertainty==1){
        earning_50[i,t]=sample(c(0, reward), size = 1, prob = c(1-prob_win, prob_win))-0.7
      } else{
        earning_50[i,t]=sample(c(0, 0.7, reward), size = 1, prob = c((1-prob_win)/2, 0.5, prob_win/2))-0.7
      }
    }
  }
}
#Simulate the payoff of different agents with the "pay one" rule----
payoff_1_optimal=rep(0,N)
payoff_1_75=rep(0,N)
payoff_1_25=rep(0,N)
payoff_1_50=rep(0,N)
payoff_2_optimal=rep(0,N)
payoff_2_75=rep(0,N)
payoff_2_25=rep(0,N)
payoff_2_50=rep(0,N)

Thres=193
for(i in 1:N){
  index=sample(1:N_trial, floor(N_trial*0.3), replace = FALSE)
  payoff_1_optimal[i]=min(max(sum(earning_optimal[i,index]),-50),110)
  payoff_1_75[i]=min(max(sum(earning_75[i,index]),-50),110)
  payoff_1_25[i]=min(max(sum(earning_25[i,index]),-50),110)
  payoff_1_50[i]=min(max(sum(earning_50[i,index]),-50),110)
  payoff_2_optimal[i]=min(max((sum(earning_optimal[i,])-Thres)*24,-50),110)
  payoff_2_75[i]=min(max((sum(earning_75[i,])-Thres)*24,-50),110)
  payoff_2_25[i]=min(max((sum(earning_25[i,])-Thres)*24,-50),110)
  payoff_2_50[i]=min(max((sum(earning_50[i,])-Thres)*24,-50),110)
}





ggplot(width=8, height=8)
par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, cex.axis=1.2,mgp = c(3.5, 1, 0))
boxplot(payoff_1_optimal, payoff_1_25, payoff_1_50, payoff_1_75, names=c("Optimal", "10% in yellow", "25% in yellow","50% in yellow"), cex=1.5, ylab="Payouts")

ggplot(width=8, height=8)
par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, cex.axis=1.2,mgp = c(3.5, 1, 0))
boxplot(payoff_2_optimal,payoff_2_25, payoff_2_50, payoff_2_75, names=c("Optimal", "25% in yellow", "50% in yellow","75% in yellow"), cex=1.5, ylab="Payouts")
