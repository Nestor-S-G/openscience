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

plotprepare <- function(...) {
  
  par(bty='n', 
      cex=0.8,
      las=1, 
      ann=T, 
      lwd=2, 
      mar=c(5, 4, 2, 1), 
      oma=c(0,0,0,0), 
      pch=19, 
      xpd=T, 
      cex.axis=0.85, 
      mgp=c(2.5, 0.72, 0),
      tcl=-0.4, ...
  )
  
}

HHcol <- '#B51700'
LLcol <- '#014D7F'
HLcol <- 'darkgrey'
LHcol <- 'lightgrey'
cooperationCol <- '#01a300'

###################################################################################################################################

### Prepare data

dat = read_csv("dat_institutions.csv")
head(dat)

dat_long = read_csv("dat_long.csv")
head(dat_long)

dat_fair = read_csv("dat_fair.csv")
head(dat_fair)

###################################################################################################################################

### Appendix C - Political orientation

## Partner preferences

#HH type as first preference
dat_long$partnerchoice1_HH <- ifelse(dat_long$pref_1 == 'HH', TRUE, FALSE)
table(dat_long$partnerchoice1_HH)
#model
m_pref1HH = glmer(partnerchoice1_HH ~ political_orientation + economic_ideology + social_ideology + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref1HH)
confint(m_pref1HH, method = c("boot"), set.seed(123))
#end

#LL type as last preference
dat_long$partnerchoice4_LL <- ifelse(dat_long$pref_4 == 'LL', TRUE, FALSE)
table(dat_long$partnerchoice4_LL)
#model
m_pref4LL = glmer(partnerchoice4_LL ~ political_orientation + economic_ideology + social_ideology + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref4LL)
confint(m_pref4LL, method = c("boot"), set.seed(123))
#end


## Cooperation

m_coop = lmer( coop_rel ~ 1 + political_orientation + economic_ideology + social_ideology + ( 1 | pp ), data=dat_long )
summary(m_coop)
confint(m_coop)
#end



## Create pairs after decision-makers created HL & LH types

dat$create_HLLH = ifelse(dat$create_types == "HL-LH",
                         1,0)
dat_HLLH = dat[dat$create_HLLH == 1,]

dat_HLLH$HLLH_mix = ifelse(dat_HLLH$create_pairs_HL == "LH" & dat_HLLH$create_pairs_LH == "HL",
                           1,0)
dat_HLLH$HLLH_seg = ifelse(dat_HLLH$create_pairs_HL == "HL" & dat_HLLH$create_pairs_LH == "LH",
                           1,0)
#model mix
model <- glm(HLLH_mix ~ political_orientation + economic_ideology + social_ideology, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#model seg
model <- glm(HLLH_seg ~ political_orientation + economic_ideology + social_ideology, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#end



## Create pairs after decision-makers created HH & LL types

dat_HHLL = dat[dat$create_HLLH == 0,]

dat_HHLL$HHLL_mix = ifelse(dat_HHLL$create_pairs_HH == "LL" & dat_HHLL$create_pairs_LL == "HH",
                           1,0)
dat_HHLL$HHLL_seg = ifelse(dat_HHLL$create_pairs_HH == "HH" & dat_HHLL$create_pairs_LL == "LL",
                           1,0)
#model mix
model <- glm(HHLL_mix ~ political_orientation + economic_ideology + social_ideology, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#model seg
model <- glm(HHLL_seg ~ political_orientation + economic_ideology + social_ideology, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#end


## Self-reported motives for creating pairs

dat$create_pairs_MC_inequality = ifelse(dat$create_pairs_MC == "Inequality", 1,0)
dat$create_pairs_MC_welfare = ifelse(dat$create_pairs_MC == "Welfare", 1,0)
dat$create_pairs_MC_similarity = ifelse(dat$create_pairs_MC == "Similarity", 1,0)
#model
model <- glm(create_pairs_MC_inequality ~ political_orientation + economic_ideology + social_ideology, data = dat, family = binomial)
summary(model)
confint(model)
#model
model <- glm(create_pairs_MC_welfare ~ political_orientation + economic_ideology + social_ideology, data = dat, family = binomial)
summary(model)
confint(model)
#model
model <- glm(create_pairs_MC_similarity ~ political_orientation + economic_ideology + social_ideology, data = dat, family = binomial)
summary(model)
confint(model)
#end
