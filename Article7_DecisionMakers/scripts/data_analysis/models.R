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

### 3.1 Free partner choice leads to segregation and increases inequality

## Partner preferences

table(dat$pref_1) / 400 * 100
table(dat$pref_4) / 400 * 100

#table 1
table(dat$type, dat$pref_1)
table(dat$type, dat$pref_4)

#HH type as first preference
dat_long$partnerchoice1_HH <- ifelse(dat_long$pref_1 == 'HH', TRUE, FALSE)
table(dat_long$partnerchoice1_HH)
#model
m_pref1HH = glmer(partnerchoice1_HH ~ type + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref1HH)
confint(m_pref1HH, method = c("boot"), set.seed(123))
#end

#LL type as last preference
dat_long$partnerchoice4_LL <- ifelse(dat_long$pref_4 == 'LL', TRUE, FALSE)
table(dat_long$partnerchoice4_LL)
#model
m_pref4LL = glmer(partnerchoice4_LL ~ type + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref4LL)
confint(m_pref4LL, method = c("boot"), set.seed(123))
#end


## Cooperation

agg <- aggregate(dat_long[dat_long$type != "TP",]$coop_rel, by=list(dat_long[dat_long$type != "TP",]$partner_type), agg_switch_na.rm)
aggse <- aggregate(dat_long[dat_long$type != "TP",]$coop_rel, by=list(dat_long[dat_long$type != "TP",]$partner_type), agg_switch_sem)
agg$SE = aggse$x

#model -  relative cooperation towards different partner types
m_coop = lmer( coop_rel ~ 1 + partner_type + ( 1 | pp ), data=dat_long[dat_long$type != "TP",] )
summary(m_coop)
confint(m_coop)

#contrast 1 tests if types are more cooperative to HH types compared to the other types
contrast1 <- c(0,-(1/3),-(1/3),-(1/3))
#contrast 2 tests if types are less cooperative to LL types compared to the other types
contrast2 <- c(0,-(1/3),-(1/3),1)
#contrast 3 tests if types are less cooperative to LL types compared to LH and HL types 
contrast3 <- c(0,-(1/2),-(1/2),1)

contrasts <- rbind(contrast1,contrast2, contrast3)

t <- glht(m_coop, linfct = contrasts)
summary(t, test=adjusted("bonferroni"))
confint(t, set.seed(123))
#end


#Gini coefficient comparison before and after cooperation
ineq(dat_long[dat_long$type != "TP",]$endowment, type = "Gini")
ineq(dat_long[dat_long$type != "TP",]$earn, type = "Gini")

###################################################################################################################################

### 3.2 Restricting free partner choice leads to an equality-efficiency trade-off

#create data-frames for mixed and segregated pairs for HH-LL & HL-LH
dat_HHLL_mix = dat_long[(dat_long$type == "HH" | dat_long$type == "LL") & (dat_long$pair == "HH_LL"),]
dat_HHLL_seg = dat_long[(dat_long$type == "HH" | dat_long$type == "LL") & (dat_long$pair == "HH_HH" | dat_long$pair == "LL_LL"),]
dat_HLLH_mix = dat_long[(dat_long$type == "HL" | dat_long$type == "LH") & (dat_long$pair == "HL_LH"),]
dat_HLLH_seg = dat_long[(dat_long$type == "HL" | dat_long$type == "LH") & (dat_long$pair == "HL_HL" | dat_long$pair == "LH_LH"),]

#calculate average per type
dat_HHLL_mix_avg <- aggregate(dat_HHLL_mix, by=list(dat_HHLL_mix$type), agg_switch)
dat_HHLL_seg_avg <- aggregate(dat_HHLL_seg, by=list(dat_HHLL_seg$type), agg_switch)
dat_HLLH_mix_avg <- aggregate(dat_HLLH_mix, by=list(dat_HLLH_mix$type), agg_switch)
dat_HLLH_seg_avg <- aggregate(dat_HLLH_seg, by=list(dat_HLLH_seg$type), agg_switch)

#calculate gini coefficients
gini_HHLL_mix <- ineq(dat_HHLL_mix_avg$earn, type = "Gini")
gini_HHLL_seg <- ineq(dat_HHLL_seg_avg$earn, type = "Gini")
gini_HLLH_mix <- ineq(dat_HLLH_mix_avg$earn, type = "Gini")
gini_HLLH_seg <- ineq(dat_HLLH_seg_avg$earn, type = "Gini")

#calculate average generated wealth
wealth_HHLL_mix <- mean((dat_HHLL_mix_avg$earn - dat_HHLL_mix_avg$endowment))
wealth_HHLL_seg <- mean((dat_HHLL_seg_avg$earn - dat_HHLL_seg_avg$endowment))
wealth_HLLH_mix <- mean((dat_HLLH_mix_avg$earn - dat_HLLH_seg_avg$endowment))
wealth_HLLH_seg <- mean((dat_HLLH_seg_avg$earn - dat_HLLH_mix_avg$endowment))

#percentage of points earned by HH and LL types under segregation
dat_HHLL_seg_avg$earn / sum(dat_HHLL_seg_avg$earn) * 100

###################################################################################################################################

### 3.3 Decision-makers self-servingly navigate the inequality-efficiency trade-off

dat$type = factor(dat$type, levels = c("TP", "HH", "HL", "LH", "LL"))

## 3.3.1 Creation of Types

#chi-square test created types
temp = dat[dat$type == "TP",]
table(temp$create_types)
observed_counts <- table(temp$create_types)
chisq_test <- chisq.test(observed_counts, p = c(0.5, 0.5))
chisq_test
#end

#model to test if creation of types differs based on decision-maker type
dat$create_HLLH = ifelse(dat$create_types == "HL-LH",
                      1,0)
#model
model <- glm(create_HLLH ~ type, data = dat, family = binomial)
summary(model)
confint(model)
#end


## 3.3.2 Creation of Pairs

#create pairs after decision-makers created HL & LH types
dat_HLLH = dat[dat$create_HLLH == 1,]

dat_HLLH$HLLH_mix = ifelse(dat_HLLH$create_pairs_HL == "LH" & dat_HLLH$create_pairs_LH == "HL",
                      1,0)
dat_HLLH$HLLH_seg = ifelse(dat_HLLH$create_pairs_HL == "HL" & dat_HLLH$create_pairs_LH == "LH",
                      1,0)
#model
model <- glm(HLLH_mix ~ type, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#model
model <- glm(HLLH_seg ~ type, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#end


#create pairs after decision-makers created HH & LL types
dat_HHLL = dat[dat$create_HLLH == 0,]

dat_HHLL$HHLL_mix = ifelse(dat_HHLL$create_pairs_HH == "LL" & dat_HHLL$create_pairs_LL == "HH",
                      1,0)
dat_HHLL$HHLL_seg = ifelse(dat_HHLL$create_pairs_HH == "HH" & dat_HHLL$create_pairs_LL == "LL",
                      1,0)
#model
model <- glm(HHLL_mix ~ type, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#model
model <- glm(HHLL_seg ~ type, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#end

#HH and LL type earnings in segregated or mixed pairs
dat_long$HH_pair = ifelse(dat_long$partner_type =="HH",
                          1, NA)
dat_long$HH_pair = ifelse(dat_long$partner_type =="LL",
                          0, dat_long$HH_pair)
#model
m_earn = lmer( earn ~ 1 + HH_pair + ( 1 | pp ), data=dat_long[dat_long$type == "HH",] )
summary(m_earn)
confint(m_earn)
#model
m_earn = lmer( earn ~ 1 + HH_pair + ( 1 | pp ), data=dat_long[dat_long$type == "LL",] )
summary(m_earn)
confint(m_earn)
#end

###################################################################################################################################

### 3.4 Additional results 

## 3.4.1 Origins of the efficiency-equality trade-off 

#fair cooperation norms in same type pairs
dat_fair$sametype_pairs = ifelse(dat_fair$pair == "HHHH" | dat_fair$pair == "HLHL" | dat_fair$pair == "LHLH" | dat_fair$pair == "LLLL",
                           1,0)
#model
m_coop = lmer( coop_rel ~ 1 + sametype_pairs + ( 1 | participant ), data=dat_fair[dat_fair$type == "TP",] )
summary(m_coop)
confint(m_coop)
#end

#model - fair cooperation norms for HH type with different partner types
m_coop = lmer( coop_rel ~ 1 + pair + ( 1 | participant ), data=dat_fair[dat_fair$type_in_pair == "HH" & dat_fair$type == "TP",] )
summary(m_coop)
confint(m_coop)
#end

#model - fair cooperation norms for LL type with different partner types
m_coop = lmer( coop_rel ~ 1 + pair + ( 1 | participant ), data=dat_fair[dat_fair$type_in_pair == "LL" & dat_fair$type == "TP",] )
summary(m_coop)
confint(m_coop)
#end

#model - fair redistribution norms for HH type with different partner types
m_earn = lmer( earn_rel ~ 1 + pair + ( 1 | participant ), data=dat_fair[dat_fair$type_in_pair == "HH" & dat_fair$type == "TP",] )
summary(m_earn)
confint(m_earn)
#end



### 3.4.2 Social preferences can reduce inequality via the creation of pairs

## Partner preferences

#HH type as first preference
dat_long$partnerchoice1_HH <- ifelse(dat_long$pref_1 == 'HH', TRUE, FALSE)
table(dat_long$partnerchoice1_HH)
#model
m_pref1HH = glmer(partnerchoice1_HH ~ svo_angle + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref1HH)
confint(m_pref1HH, method = c("boot"), set.seed(123))
#end

#LL type as last preference
dat_long$partnerchoice4_LL <- ifelse(dat_long$pref_4 == 'LL', TRUE, FALSE)
table(dat_long$partnerchoice4_LL)
#model
m_pref4LL = glmer(partnerchoice4_LL ~ svo_angle + ( 1 | pp ), data = dat_long, family = "binomial")
summary(m_pref4LL)
confint(m_pref4LL, method = c("boot"), set.seed(123))
#end


## Cooperation

m_coop = lmer( coop_rel ~ 1 + svo_angle + ( 1 | pp ), data=dat_long )
summary(m_coop)
confint(m_coop)
#end



#create pairs after decision-makers created HL & LH types
dat_HLLH = dat[dat$create_HLLH == 1,]
dat_HLLH$HLLH_mix = ifelse(dat_HLLH$create_pairs_HL == "LH" & dat_HLLH$create_pairs_LH == "HL",
                           1,0)
dat_HLLH$HLLH_seg = ifelse(dat_HLLH$create_pairs_HL == "HL" & dat_HLLH$create_pairs_LH == "LH",
                           1,0)
#model
model <- glm(HLLH_mix ~ svo_angle, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#model
model <- glm(HLLH_seg ~ svo_angle, data = dat_HLLH, family = binomial)
summary(model)
confint(model)
#end



#create pairs after decision-makers created HH & LL types
dat_HHLL = dat[dat$create_HLLH == 0,]
dat_HHLL$HHLL_mix = ifelse(dat_HHLL$create_pairs_HH == "LL" & dat_HHLL$create_pairs_LL == "HH",
                           1,0)
dat_HHLL$HHLL_seg = ifelse(dat_HHLL$create_pairs_HH == "HH" & dat_HHLL$create_pairs_LL == "LL",
                           1,0)
#model
model <- glm(HHLL_mix ~ svo_angle, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#model
model <- glm(HHLL_seg ~ svo_angle, data = dat_HHLL, family = binomial)
summary(model)
confint(model)
#end


#self-reported motive for creating pairs
dat$create_pairs_MC_inequality = ifelse(dat$create_pairs_MC == "Inequality", 1,0)
dat$create_pairs_MC_welfare = ifelse(dat$create_pairs_MC == "Welfare", 1,0)
dat$create_pairs_MC_similarity = ifelse(dat$create_pairs_MC == "Similarity", 1,0)
#model
model <- glm(create_pairs_MC_inequality ~ svo_angle, data = dat, family = binomial)
summary(model)
confint(model)
#model
model <- glm(create_pairs_MC_welfare ~ svo_angle, data = dat, family = binomial)
summary(model)
confint(model)
#model
model <- glm(create_pairs_MC_similarity ~ svo_angle, data = dat, family = binomial)
summary(model)
confint(model)
#end

