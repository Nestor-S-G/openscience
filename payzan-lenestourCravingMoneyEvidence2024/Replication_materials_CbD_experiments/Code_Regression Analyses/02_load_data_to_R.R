
library(EnvStats)

rt_data_all = read.csv("REPLACE_WITH_DATA_FOLDER/RT_Data_all_withRT.csv")

# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct', 'Bet_Per_Session',
             'ShotBelow8', 'Outlier_Shot')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1,
                    Out_Session = 1, Bet_Count = 1, Out_Present = 1,
                    Correct = 1, Bet_Per_Session = 1,
                    ShotBelow8 = 1, Outlier_Shot = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      shot = NA
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      shotBelow8 = 0
      if(any(abs(x$Shot) > 7)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 7) {
            shot = abs(x$Shot[k])
            if(abs(x$Shot[k]) < 8) {
              shotBelow8 = 1
            }
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 7)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          first_bet_n <- k
          if(k < 11) {
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 7)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet),
                     ShotBelow8 = shotBelow8,
                     Outlier_Shot = shot)
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = NA

for(i in 1:nrow(comp_all)) {
  
  j = which(comp_all$ID == comp_all$ID[i])
  k = j[1]
  if(i > k) {
    if(comp_all$ID[i] == comp_all$ID[i - 1]) {
      comp_all$Last_Bet[i] = comp_all$Bet[i - 1]
      comp_all$Last_Outcome[i] = comp_all$Outcome[i - 1]
    }
    
    if(i - 10 >= k) {
      comp_all$Last_10_Outcomes[i] = mean(comp_all$Outcome[(i-10):(i-1)])
      comp_all$Last_5_Outcomes[i] = mean(comp_all$Outcome[(i-5):(i-1)])
      comp_all$Last_3_Outcomes[i] = mean(comp_all$Outcome[(i-3):(i-1)])
    } else if(i - 5 >= k) {
      comp_all$Last_10_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
      comp_all$Last_5_Outcomes[i] = mean(comp_all$Outcome[(i-5):(i-1)])
      comp_all$Last_3_Outcomes[i] = mean(comp_all$Outcome[(i-3):(i-1)])
    } else if(i - 3 >= k) {
      comp_all$Last_10_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
      comp_all$Last_5_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
      comp_all$Last_3_Outcomes[i] = mean(comp_all$Outcome[(i-3):(i-1)])
    } else {
      comp_all$Last_10_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
      comp_all$Last_5_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
      comp_all$Last_3_Outcomes[i] = mean(comp_all$Outcome[k:(i-1)])
    }
  }
}

Last_Bet = comp_all$Last_Bet
Last_Outcome = comp_all$Last_Outcome
Last_3_Outcomes = comp_all$Last_3_Outcomes
Last_5_Outcomes = comp_all$Last_5_Outcomes
Last_10_Outcomes = comp_all$Last_10_Outcomes

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                               comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_7 = comp_all


# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct', 'Bet_Per_Session')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1, Out_Session = 1,
                    Bet_Count = 1, Out_Present = 1, Correct = 1,
                    Bet_Per_Session = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      if(any(abs(x$Shot) > 8)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 8) {
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 8)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          if(k < 11) {
            first_bet_n <- k
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 8)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet))
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = 
  cbind(Last_Bet, Last_Outcome, Last_3_Outcomes, Last_5_Outcomes, Last_10_Outcomes)

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                               comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_8 = comp_all

# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct', 'Bet_Per_Session')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1, Out_Session = 1,
                    Bet_Count = 1, Out_Present = 1, Correct = 1,
                    Bet_Per_Session = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      if(any(abs(x$Shot) > 9)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 9) {
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 9)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          first_bet_n <- k
          if(k < 11) {
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 9)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet))
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = 
  cbind(Last_Bet, Last_Outcome, Last_3_Outcomes, Last_5_Outcomes, Last_10_Outcomes)

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                        comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_9 = comp_all


# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct', 'Bet_Per_Session',
             'ShotBelow8', 'Outlier_Shot')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1, Out_Session = 1,
                    Bet_Count = 1, Out_Present = 1, 
                    Correct = 1, Bet_Per_Session = 1,
                    ShotBelow8 = 1, Outlier_Shot = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      shotBelow8 = 0
      if(any(abs(x$Shot) > 7 & x$Outcome == -40)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 7 & x$Outcome[k] == -40) {
            shot = abs(x$Shot[k])
            if(abs(x$Shot[k]) < 8) {
              shotBelow8 = 1
            }
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 7)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          if(k < 11) {
            first_bet_n <- k
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 7)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet),
                     ShotBelow8 = shotBelow8,
                     Outlier_Shot = shot)
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = 
  cbind(Last_Bet, Last_Outcome, Last_3_Outcomes, Last_5_Outcomes, Last_10_Outcomes)

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                               comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_7mm = comp_all


# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct',
             'Bet_Per_Session')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1, Out_Session = 1,
                    Bet_Count = 1, Out_Present = 1, Correct = 1, 
                    Bet_Per_Session = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      if(any(abs(x$Shot) > 8 & x$Outcome == -40)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 8 & x$Outcome[k] == -40) {
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 8)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          if(k < 11) {
            first_bet_n <- k
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 8)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet))
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = 
  cbind(Last_Bet, Last_Outcome, Last_3_Outcomes, Last_5_Outcomes, Last_10_Outcomes)

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                               comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_8mm = comp_all

# Labeling
comp_all = rt_data_all[1,]
comp_all[, c('Session_Number', 'Time', 'Trial', 'Trial_From_BS',
             'First_Bet', 'First_Bet_N', 'PP_By_Session', 'Out_Session', 'Out_Total',
             'Bet_Count', 'Out_Present', 'Correct', 'Bet_Per_Session')] = NA
j = 1
for(exp in unique(rt_data_all$Experiment)) {
  exp_data = rt_data_all[rt_data_all$Experiment == exp, ]
  
  for(sub in unique(exp_data$Sample.ID)) {
    
    sub_data = exp_data[exp_data$Sample.ID == sub, ]
    j = 1
    appNum = 0
    masNum = 0
    Total_Out = 0
    df = data.frame(Session_Number = 1, Time = 1, Trial = 1, Trial_From_BS = 1, 
                    First_Bet = 1, First_Bet_N = 1, PP_By_Session = 1, Out_Session = 1,
                    Bet_Count = 1, Out_Present = 1,
                    Correct = 1, Bet_Per_Session = 1)
    
    for(i in seq(20, nrow(sub_data), 20)) {
      
      x = sub_data[j:i, ]
      
      if(x$Apprentice[1] == 1) {
        appNum = appNum + 1
        x$Ses = rep(appNum, nrow(x))
      } else {
        masNum = masNum + 1
        x$Ses = rep(masNum, nrow(x))
      }
      
      x$Picked = 0
      x$Time = 'Before'
      x$Trial_From_BS = NA
      x$Bet_Count = 0
      if(any(abs(x$Shot) > 9 & x$Outcome == -40)) {
        for(k in 1:nrow(x)) {
          if(abs(x$Shot[k]) > 9 & x$Outcome[k] == -40) {
            break
          }
        }
        
        x$Trial_From_BS = 1:20 - k
        if(k == 1) {
          x$Time[2:nrow(x)] = 'After'
        } else if(k != nrow(x)) {
          x$Time[(k + 1):nrow(x)] = 'After'
        }
        
        if(sum(x$Bet[x$Time == 'After']) > 0) {
          x$Picked = 1
          x$Bet_Count = sum(x$Bet)
        }
      }
      
      out_present = 0
      if(any(abs(x$Shot) > 9)) {
        out_present = 1
      }
      
      Correct = NA
      if(x$Experiment[1] %in% c('Experiment3', 'Experiment5')) {
        if(x$Apprentice[nrow(x)] == x$Guess[nrow(x)]) {
          Correct = 1
        } else {
          Correct = 0
        }
      }
      
      FirstBet = NA
      for(k in 1:nrow(x)) {
        if(x$Bet[k] == 1) {
          first_bet_n <- k
          if(k < 11) {
            FirstBet = 'Early'
          } else {
            FirstBet = 'Late'
          }
          break
        }
        if(k == nrow(x)) {
          first_bet_n <- 21
          FirstBet = 'Never'
        }
      }
      
      outliers = sum(abs(x$Shot) > 9)
      Total_Out = Total_Out + outliers
      
      y = data.frame(Session_Number = x$Ses, Time = x$Time, 
                     Trial = 1:nrow(x), Trial_From_BS = x$Trial_From_BS,
                     First_Bet = FirstBet,
                     First_Bet_N = first_bet_n,
                     PP_By_Session = x$Picked, 
                     Out_Session = rep(outliers, nrow(x)),
                     Bet_Count = x$Bet_Count,
                     Out_Present = out_present,
                     Correct = Correct,
                     Bet_Per_Session = sum(x$Bet))
      
      df = rbind(df, y)
      j = i + 1
      
    }
    
    df = df[2:nrow(df), ]
    df$Out_Total = Total_Out
    
    sub_data = cbind(sub_data, df)
    
    comp_all = rbind(comp_all, sub_data)
  }
}

comp_all = comp_all[2:nrow(comp_all), ]


# Add unique ID per participant
j = 1000
for(exp in unique(comp_all$Experiment)) {
  
  comp_all$ID[comp_all$Experiment == exp] = j + comp_all$Sample.ID[comp_all$Experiment == exp]
  
  j = j + 1000
  
}


# Add previous bet and last few outcomes
comp_all[, c('Last_Bet', 'Last_Outcome', 'Last_3_Outcomes',
             'Last_5_Outcomes', 'Last_10_Outcomes')] = 
  cbind(Last_Bet, Last_Outcome, Last_3_Outcomes, Last_5_Outcomes, Last_10_Outcomes)

comp_all = comp_all[comp_all$RT > 0 | is.na(comp_all$RT), ]
comp_all$bcRT = boxcoxTransform(comp_all$RT, lambda = -0.3)

# Categorize penny pickers

for(i in unique(comp_all$Experiment)) {
  
  x = comp_all[comp_all$Experiment == i, ]
  
  for(j in unique(x$Sample.ID)) {
    if(i == "Experiment2") {
      if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                          comp_all$Apprentice == 1]) > 1) {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
      } else {
        comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
      }
    } else if(sum(comp_all$Bet[comp_all$Sample.ID == j & comp_all$Experiment == i & 
                               comp_all$Time == 'After' & comp_all$Apprentice == 1]) > 1) {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 1
    } else {
      comp_all$PP[comp_all$Experiment == i & comp_all$Sample.ID == j] = 0
    }
  }
}


comp_all_9mm = comp_all




