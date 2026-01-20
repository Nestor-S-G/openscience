# Libraries
library(readr)
library(ggplot2)
library(dplyr)
library(lme4)
library(lmerTest)
library(RColorBrewer)
library(tidyr)
library(ineq)
library(car)
library(reshape2)
library(multcomp)

#load functions
sem <- function(x, na.rm=F)  { 
  dev <- sd(x, na.rm=na.rm)
  len <- ifelse(na.rm == T, length(x[!is.na(x)]), length(x))
  stderror <- dev/sqrt(len)
  return(stderror)
} 

agg_switch <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else mean(x)
agg_switch_sem <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sem(x)
agg_switch_sum <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sum(x)
agg_switch_na.rm <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else mean(x, na.rm=T)
agg_switch_sem.rm <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sem(x, na.rm=T)

###################################################################################################################################

### Prepare data

dat = read_csv("dat_institutions.csv")
head(dat)

dat_long = read_csv("dat_long.csv")
head(dat_long)

dat_fair = read_csv("dat_fair.csv")
head(dat_fair)

###################################################################################################################################

### Partner Choice Algorithm

#remove TP data
preferences = dat[dat$type != "TP",]

#create matrices to store pair information
preferences$pair_info <- rep(NA, nrow(preferences))
pairmatrix <- matrix("", nrow = nrow(preferences), ncol = nrow(preferences))

#create vector to keep track of participants who have been paired
paired <- rep(FALSE, nrow(preferences))

#create empty list to store information of each iteration
pair_info_list <- vector("list", length = 1000)
earn_PGG_total_list <- vector("list", length = 1000)
gini_list <- vector("list", length = 1000)

#run loop over partner preferences and calculate earnings
for (iteration in 1:1000) {
  #set a new seed for each iteration
  set.seed(iteration)
  
  #create random order of participants to pay them based on their preferences
  rand_ord = sample(nrow(preferences))
  preferences = preferences[rand_ord, ]
  
  #create matrices to store pair information
  preferences$pair_info <- rep(NA, nrow(preferences))
  pairmatrix <- matrix("", nrow = nrow(preferences), ncol = nrow(preferences))
  
  #create a vector to keep track of participants who have been paired
  paired <- rep(FALSE, nrow(preferences))
  
  #loop pref_1 with pref_1
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_1[i]) && !is.na(preferences$type[i])) {  #check if participant i has not been paired yet and has no missing values
      for (j in (i+1):nrow(preferences)) {  #avoid pairing with themselves and duplicate pairs
        if (!paired[j] && !is.na(preferences$pref_1[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_1[i] == preferences$type[j] && preferences$pref_1[j] == preferences$type[i]) {
          #participants i and j have compatible preferences and types
          p <- (i^2) + (j^3)  #pair identifier
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ")
          paired[i] <- TRUE  #mark participants i and j as paired
          paired[j] <- TRUE
          
          #store the pair number
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_1 with pref_2
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_1[i]) && !is.na(preferences$type[i])) {  
      for (j in (i+1):nrow(preferences)) {  
        if (!paired[j] && !is.na(preferences$pref_1[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_1[i] == preferences$type[j] && preferences$pref_2[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_2 with pref_2
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_2[i]) && !is.na(preferences$type[i])) {
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && !is.na(preferences$pref_2[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_2[i] == preferences$type[j] && preferences$pref_2[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_1 with pref_3
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_2[i]) && !is.na(preferences$type[i])) {
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && !is.na(preferences$pref_1[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_1[i] == preferences$type[j] && preferences$pref_3[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_2 with pref_3
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_2[i]) && !is.na(preferences$type[i])) {
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && !is.na(preferences$pref_2[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_2[i] == preferences$type[j] && preferences$pref_3[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_3 with pref_3
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_3[i]) && !is.na(preferences$type[i])) {
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && !is.na(preferences$pref_3[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_3[i] == preferences$type[j] && preferences$pref_3[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ")
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_1 with pref_4
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_4[i]) && !is.na(preferences$type[i])) { 
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && !is.na(preferences$pref_4[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_1[i] == preferences$type[j] && preferences$pref_4[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_2 with pref_4
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_4[i]) && !is.na(preferences$type[i])) { 
      for (j in (i+1):nrow(preferences)) { 
        if (!paired[j] && !is.na(preferences$pref_4[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_2[i] == preferences$type[j] && preferences$pref_4[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_3 with pref_4
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_4[i]) && !is.na(preferences$type[i])) { 
      for (j in (i+1):nrow(preferences)) { 
        if (!paired[j] && !is.na(preferences$pref_4[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_3[i] == preferences$type[j] && preferences$pref_4[j] == preferences$type[i]) {
          p <- (i^2) + j
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ")  
          paired[i] <- TRUE 
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break 
        }
      }
    }
  }
  
  #set pair numbers to NA for participants who couldn't be paired
  preferences$pair_info[!paired] <- NA
  
  #loop pref_4 with pref_4
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && !is.na(preferences$pref_4[i]) && !is.na(preferences$type[i])) {  
      for (j in (i+1):nrow(preferences)) { 
        if (!paired[j] && !is.na(preferences$pref_4[j]) && !is.na(preferences$type[j]) && 
            preferences$pref_4[i] == preferences$type[j] && preferences$pref_4[j] == preferences$type[i]) {
          p <- (i^2) + j 
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ") 
          paired[i] <- TRUE  
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p 
          preferences$pair_info[j] <- p 
          break 
        }
      }
    }
  }
  
  # Loop to pair remaining NA participants
  for (i in 1:(nrow(preferences) - 1)) {
    if (!paired[i] && is.na(preferences$pair_info[i])) {
      for (j in (i+1):nrow(preferences)) {
        if (!paired[j] && is.na(preferences$pair_info[j])) {
          p <- (i^2) + j 
          pairmatrix[i, j] <- paste("Pair", p, sep = " ")
          pairmatrix[j, i] <- paste("Pair", p, sep = " ")
          paired[i] <- TRUE
          paired[j] <- TRUE
          
          preferences$pair_info[i] <- p
          preferences$pair_info[j] <- p
          break
        }
      }
    }
  }
  
###################################################################################################################################
  
  ### Calculate public good earnings
  
  #create variable for decisions of partner type
  preferences$partner_type_payment <- rep(NA, nrow(preferences))
  pairs <- unique(preferences$pair_info)
  
  #loop through all pairs
  for (pair in pairs) {
    #find participants in the current pair
    pair_participants <- which(preferences$pair_info == pair)
    
    #check if both participants in the pair are found
    if (length(pair_participants) == 2) {
      #get the types of both participants
      partner_type_payment <- preferences$type[pair_participants[1]]
      preferences$partner_type_payment[pair_participants[2]] <- partner_type_payment
      preferences$partner_type_payment[pair_participants[1]] <- partner_type_payment
    }
  }
  
  #calculate how much participants would cooperate given their partner 
  preferences$coop_pay = NA
  preferences$coop_pay = ifelse(preferences$partner_type_payment == "HH", preferences$coop_HH, preferences$coop_pay)
  preferences$coop_pay = ifelse(preferences$partner_type_payment == "HL", preferences$coop_HL, preferences$coop_pay)
  preferences$coop_pay = ifelse(preferences$partner_type_payment == "LH", preferences$coop_LH, preferences$coop_pay)
  preferences$coop_pay = ifelse(preferences$partner_type_payment == "LL", preferences$coop_LL, preferences$coop_pay)
  preferences$keep_pay = preferences$endowment - preferences$coop_pay 
  preferences$added_to_PGG_pay =  preferences$coop_pay * preferences$productivity
  
  #calculate how much participants receive from the public good
  preferences$received_PGG_pay <- rep(0, nrow(preferences))
  
  #loop through the pairs
  for (pair in pairs) {
    #find participants in the current pair
    pair_participants <- which(preferences$pair_info == pair)
    
    #check if both participants in the pair are found
    if (length(pair_participants) == 2) {
      #get the contributions of both participants
      contribution_1 <- preferences$added_to_PGG_pay[pair_participants[1]]
      contribution_2 <- preferences$added_to_PGG_pay[pair_participants[2]]
      
      #calculate the received amount for both participants in the pair
      received_amount <- (contribution_1 + contribution_2) / 2
      
      #assign the received amount from the public good for both participants
      preferences$received_PGG_pay[pair_participants[1]] <- received_amount
      preferences$received_PGG_pay[pair_participants[2]] <- received_amount
    }
  }
  
  preferences$earn_PGG_total = preferences$received_PGG_pay + preferences$keep_pay
  preferences$earn_PGG_total
  
  #create variable that indicates pair
  preferences$pair = NA
  preferences$pair = ifelse(preferences$type == "HH" & preferences$partner_type_payment == "HH", "HH_HH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HH" & preferences$partner_type_payment == "HL", "HH_HL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HH" & preferences$partner_type_payment == "LH", "HH_LH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HH" & preferences$partner_type_payment == "LL", "HH_LL", preferences$pair)
  
  preferences$pair = ifelse(preferences$type == "HL" & preferences$partner_type_payment == "HH", "HH_HL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HL" & preferences$partner_type_payment == "HL", "HL_HL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HL" & preferences$partner_type_payment == "LH", "HL_LH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "HL" & preferences$partner_type_payment == "LL", "HL_LL", preferences$pair)
  
  preferences$pair = ifelse(preferences$type == "LH" & preferences$partner_type_payment == "HH", "HH_LH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LH" & preferences$partner_type_payment == "HL", "HL_LH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LH" & preferences$partner_type_payment == "LH", "LH_LH", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LH" & preferences$partner_type_payment == "LL", "LH_LL", preferences$pair)
  
  preferences$pair = ifelse(preferences$type == "LL" & preferences$partner_type_payment == "HH", "HH_LL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LL" & preferences$partner_type_payment == "HL", "HL_LL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LL" & preferences$partner_type_payment == "LH", "LH_LL", preferences$pair)
  preferences$pair = ifelse(preferences$type == "LL" & preferences$partner_type_payment == "LL", "LL_LL", preferences$pair)
  
  pair_info_list[[iteration]] <- preferences$pair
  earn_PGG_total_list[[iteration]] <- preferences$earn_PGG_total
  gini_list[[iteration]] = ineq(preferences$earn_PGG_total, type = "Gini")

}
  
#check info for all iterations
pair_info_list
earn_PGG_total_list
gini_list

#pair results
pair_info <- unlist(pair_info_list)
table(pair_info) / sum(table(pair_info)) * 100
#same type pairs
21.060635 + 20.837543 + 22.363919 + 23.761242 
100-88.02334

#Gini coefficient comparison before and after partner choice
ineq(dat[dat$type != "TP",]$endowment, type = "Gini")
mean(unlist(gini_list))
max(unlist(gini_list))
min(unlist(gini_list))

## Gini coefficient comparison partner choice with forced mixing for HH and LL types
#create data-frames for mixed and segregated pairs for HH-LL & HL-LH
dat_HHLL_mix = dat_long[(dat_long$type == "HH" | dat_long$type == "LL") & (dat_long$pair == "HH_LL"),]
#calculate average per type
dat_HHLL_mix_avg <- aggregate(dat_HHLL_mix, by=list(dat_HHLL_mix$type), agg_switch)
#calculate Gini coefficients
gini_HHLL_mix <- ineq(dat_HHLL_mix_avg$earn, type = "Gini")
#compare Gini with mixing of types
mean(unlist(gini_list)) - gini_HHLL_mix
