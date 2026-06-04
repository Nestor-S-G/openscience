library(tidyverse)
library(pwr)
library(moments)
library(brglm2)
library(pscl)
library(performance)
library(twosamples)
library(scales)
library(lme4)
library(blme)

se <- function (x) {
  se = sd(x, na.rm = TRUE)/sqrt(length(x))
  return(se)
}

Modes <- function(x) {
  ux <- unique(x)
  tab <- tabulate(match(x, ux))
  ux[tab == max(tab)]
}


## p. 8, Cshisq power medium, N=168
cohens_w <- pwr.chisq.test(N = 168, df = 1, w = 0.3)
cohens_w$power


## p. 8, Cohen's D power medium/large, N=99
length(unique(comp_all_7$ID[comp_all_7$Experiment %in% c("Experiment3", "Experiment5") & comp_all_7$PP == 1]))
pwr.t2n.test(n1 = 99-47, n2 = 47, d = c(0.5, 0.8))


## p. 9 Chisq medium power, N=184
cohens_w <- pwr.chisq.test(N = 184, df = 1, w = 0.3)
cohens_w$power


## p. 9 Chisq medium power, N=223
cohens_w <- pwr.chisq.test(N = 223, df = 1, w = 0.3)
cohens_w$power


## p. 24, table S1
comp_all_7 %>%
  filter(Experiment %in% c("Experiment2", "Experiment3", "Experiment5")) %>%
  group_by(Experiment) %>%
  summarize(N = n(),
            Mean = mean(RT),
            SD = sd(RT),
            Median = median(RT),
            Min = min(RT),
            Max = max(RT),
            Skew = skewness(RT))

comp_all_7 %>%
  filter(Experiment %in% c("Experiment2", "Experiment3", "Experiment5")) %>%
  summarize(N = n(),
            Mean = mean(RT),
            SD = sd(RT),
            Median = median(RT),
            Min = min(RT),
            Max = max(RT),
            Skew = skewness(RT))


## p. 25, table S2
# Swap data frame for:
# 7m = comp_all_7
# 8m = comp_all_8
# 9m = comp_all_9
# 7mm = comp_all_7mm
# 8mm = comp_all_8mm
# 9mm = comp_all_9mm
comp_all_7 %>%
  filter(Experiment %in% c("Experiment1",
                           "Experiment2",
                           "Experiment3",
                           "Experiment4",
                           "Experiment5")) %>%
  group_by(ID) %>%
  slice_head(n = 1) %>%
  group_by(Experiment) %>%
  summarize(pp_prevalence = mean(PP)) %>%
  ungroup

## p. 26, table S3
comp_all_7mm %>%
  filter(Experiment != "sessions_with_MBA_students") %>%
  group_by(Experiment, PP, ID) %>%
  summarize(black_swans_7 = sum(abs(Shot) > 7),
            black_swans_8 = sum(abs(Shot) > 8),
            black_swans_9 = sum(abs(Shot) > 9)) %>%
  group_by(Experiment, PP) %>%
  summarize(black_swans_7_mean = mean(black_swans_7),
            black_swans_8_mean = mean(black_swans_8),
            black_swans_9_mean = mean(black_swans_9)) %>%
  ungroup

# Totals
comp_all_7mm %>%
  filter(Experiment != "sessions_with_MBA_students") %>%
  group_by(PP, ID) %>%
  summarize(black_swans_7 = sum(abs(Shot) > 7),
            black_swans_8 = sum(abs(Shot) > 8),
            black_swans_9 = sum(abs(Shot) > 9)) %>%
  group_by(PP) %>%
  summarize(black_swans_7_mean = mean(black_swans_7),
            black_swans_8_mean = mean(black_swans_8),
            black_swans_9_mean = mean(black_swans_9)) %>%
  ungroup

## p. 27, table S4 A-B
# Panel A
pp_start_split <- comp_all_7mm %>%
  filter(PP == 1 & Apprentice == 1 &
           Experiment == 'Experiment2') %>%
  group_by(ID, Session_Number) %>%
  mutate(did_bet = if_else(sum(Bet) > 0, 1, 0)) %>%
  ungroup

pp_start_split_0 <- pp_start_split %>%
  filter(did_bet == 0) %>%
  group_by(ID, Session_Number) %>%
  summarize(first_bet = 21) %>%
  ungroup

pp_start_split_out <- pp_start_split %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  #  rbind(pp_start_split_0) %>%
  group_by(ID) %>%
  summarize(first_bet = mean(first_bet)) %>%
  ungroup %>%
  summarize(mean = mean(first_bet),
            sd = sd(first_bet),
            median = median(first_bet),
            mode = Modes(first_bet))

pp_start_split_out

# Panel B
# Swap between comp_all_7mm, comp_all_8mm, and comp_all_9mm
pp_start_split <- comp_all_9mm %>%
  filter(PP == 1 & Time == "After" & Apprentice == 1 &
           Experiment %in% c('Experiment1', 'Experiment3',
                             'Experiment5')) %>%
  group_by(ID, Session_Number, Experiment) %>%
  mutate(did_bet = if_else(sum(Bet) > 0, 1, 0)) %>%
  ungroup

pp_start_split_0 <- pp_start_split %>%
  filter(did_bet == 0) %>%
  group_by(ID, Session_Number, Experiment) %>%
  summarize(first_bet = 21) %>%
  ungroup

pp_start_split_out <- pp_start_split %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number, Experiment) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  #  rbind(pp_start_split_0) %>%
  group_by(ID, Experiment) %>%
  summarize(first_bet = mean(first_bet)) %>%
  group_by(Experiment) %>%
  summarize(mean = mean(first_bet))

pp_start_split_out

# Together exp 1,3,4,5
pp_start_split_out <- pp_start_split %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  #  rbind(pp_start_split_0) %>%
  group_by(ID) %>%
  summarize(first_bet = mean(first_bet)) %>%
  ungroup %>%
  summarize(mean = mean(first_bet),
            sd = sd(first_bet),
            median = median(first_bet),
            mode = Modes(first_bet))

pp_start_split_out


## p. 28, table S5
# Swap between comp_all_7mm, comp_all_8mm, and comp_all_9mm
comp_all_9mm %>%
  filter(Experiment != 'sessions_with_MBA_students') %>%
  group_by(ID, PP, Apprentice, Experiment) %>%
  summarize(betting_rate = mean(Bet)) %>%
  group_by(Experiment, PP, Apprentice) %>%
  summarize(betting_rate = mean(betting_rate))

comp_all_9mm %>%
  filter(Experiment != 'sessions_with_MBA_students') %>%
  group_by(ID, PP, Apprentice) %>%
  summarize(betting_rate = mean(Bet)) %>%
  group_by(PP, Apprentice) %>%
  summarize(betting_rate = mean(betting_rate))


## p. 30, table S7
agg_glm = aggregate(PP ~ Out_Total + ID + Experiment,
                    data = comp_all_7mm[comp_all_7mm$Experiment != 'sessions_with_MBA_students', ], 
                    FUN = mean) %>%
  mutate(Black_Swan_N = Out_Total)

# Drop unused level
agg_glm$Experiment = droplevels(agg_glm$Experiment)

# Add first bet
for(id in unique(agg_glm$ID)) {
  x = Modes(comp_all_7mm$First_Bet[comp_all_7mm$ID == id])
  agg_glm$First_Bet[agg_glm$ID == id] = x[1]
}

# set up model
brglm_mod = glm(PP ~ Experiment + Black_Swan_N + First_Bet, 
                data = agg_glm, family = binomial(link = 'logit'), 
                method = 'brglmFit')

summary(brglm_mod)

pR2(brglm_mod)


## p. 31, table S8
# Swap between comp_all_7mm, comp_all_8mm, comp_all_9mm
agg_glm <- comp_all_7mm %>%
  filter(Experiment %in% c("Experiment3", "Experiment5") &
           Trial == 20) %>%
  mutate(guess_bowman = if_else(Outcome_Guess > 0, 1, 0)) %>%
  group_by(PP, ID, Out_Total, Experiment) %>%
  summarize(accuracy = mean(guess_bowman)) %>%
  ungroup %>%
  mutate(First_Bet = 0,
         Black_Swan_N = Out_Total)

# Add first bet
for(id in unique(agg_glm$ID)) {
  x = Modes(comp_all_7mm$First_Bet[comp_all_7mm$ID == id])
  agg_glm$First_Bet[agg_glm$ID == id] = x[1]
}

# set up model
brglm_mod = glm(PP ~ Experiment + scale(Black_Swan_N) + First_Bet + scale(accuracy), 
                data = agg_glm, family = binomial(link = 'logit'), 
                method = 'brglmFit')


summary(brglm_mod)

pR2(brglm_mod)


## p. 32, table S9
# Swap between comp_all_7mm and comp_all_8mm (same as 9mm)
glm_trial <- comp_all_7mm[
  comp_all_7mm$Apprentice == 1 &
    comp_all_7mm$Time == 'After' &
    comp_all_7mm$PP == 1 &
    comp_all_7mm$Experiment != 'sessions_with_MBA_students', ]

# Create binary first bet variable
glm_trial$Trial_From_BS_binary <- 0
glm_trial$Trial_From_BS_binary[glm_trial$Trial_From_BS > 2] <- 1

# Set up model, ShotBelow8 variable only for comp_all_7mm
glmm_1 <- bglmer(Bet ~ factor(Experiment) +
                   Trial_From_BS_binary +
                   Last_Bet +
                   scale(Wealth) +
                   scale(Last_5_Outcomes) +
                   scale(Session_Number) +
                   ShotBelow8 +
                   (1 | ID),
                 data = glm_trial,
                 fixef.prior = t,
                 family = binomial(link = 'logit'),
                 glmerControl(optCtrl = list(maxfun = 2e5)))

summary(glmm_1)

# Theoretical Conditional R^2
r2_nakagawa(glmm_1)$R2_conditional


## p. 33, table S10
glm_trial <- comp_all_9mm %>%
  filter(Experiment != 'sessions_with_MBA_students')

# Create binary first bet variable
glm_trial$Trial_From_BS_binary <- 0
glm_trial$Trial_From_BS_binary[glm_trial$Trial_From_BS > 2] <- 1

# Set up models
glmm_base <- bglmer(Bet ~ factor(Experiment) +
                      Apprentice +
                      PP +
                      Last_Bet +
                      scale(Wealth) +
                      scale(Last_5_Outcomes) +
                      scale(Session_Number) +
                      (1 | ID),
                    data = glm_trial,
                    fixef.prior = t,
                    family = binomial(link = 'logit'),
                    glmerControl(optCtrl = list(maxfun = 2e5)))

glmm_1 <- bglmer(Bet ~ factor(Experiment) +
                   Apprentice +
                   PP +
                   Last_Bet +
                   scale(Wealth) +
                   scale(Last_5_Outcomes) +
                   scale(Session_Number) +
                   PP * Last_Bet +
                   (1 | ID),
                 data = glm_trial,
                 fixef.prior = t,
                 family = binomial(link = 'logit'),
                 glmerControl(optCtrl = list(maxfun = 2e5)))

glmm_2 <- bglmer(Bet ~ factor(Experiment) +
                   Apprentice +
                   PP +
                   Last_Bet +
                   scale(Wealth) +
                   scale(Last_5_Outcomes) +
                   scale(Session_Number) +
                   PP * (Last_Bet + scale(Wealth)) +
                   (1 | ID),
                 data = glm_trial,
                 fixef.prior = t,
                 family = binomial(link = 'logit'),
                 glmerControl(optCtrl = list(maxfun = 2e5)))

glmm_3 <- bglmer(Bet ~ factor(Experiment) +
                   Apprentice +
                   PP +
                   Last_Bet +
                   scale(Wealth) +
                   scale(Last_5_Outcomes) +
                   scale(Session_Number) +
                   PP * (Last_Bet + scale(Wealth) + scale(Last_5_Outcomes)) +
                   (1 | ID),
                 data = glm_trial,
                 fixef.prior = t,
                 family = binomial(link = 'logit'),
                 glmerControl(optCtrl = list(maxfun = 2e5)))

glmm_4 <- bglmer(Bet ~ factor(Experiment) +
                   Apprentice +
                   PP +
                   Last_Bet +
                   scale(Wealth) +
                   scale(Last_5_Outcomes) +
                   scale(Session_Number) +
                   PP * (Last_Bet + scale(Wealth) + scale(Last_5_Outcomes) + scale(Session_Number)) +
                   (1 | ID),
                 data = glm_trial,
                 fixef.prior = t,
                 family = binomial(link = 'logit'),
                 glmerControl(optCtrl = list(maxfun = 2e5)))

summary(glmm_base)

# Theoretical Conditional R^2
r2_nakagawa(glmm_base)$R2_conditional

AIC(glmm_base, glmm_1, glmm_2, glmm_3, glmm_4)

# Comparing models to get chi-sq
anova(glmm_base, glmm_1)


## p. 39, table S15
# Swap out alpha (0.05, 0.1) and power (0.8, 0.9) for each test

# 1
pwr.chisq.test(N = 168, df = 1, sig.level = 0.05, power = 0.8)

# 2
n_pp <- length(unique(comp_all_7$ID[comp_all_7$Experiment %in% c("Experiment3", "Experiment5") &
                                      comp_all_7$PP == 1]))
n_others <- length(unique(comp_all_7$ID[comp_all_7$Experiment %in% c("Experiment3", "Experiment5") &
                                          comp_all_7$PP == 0]))

pwr.t2n.test(n1 = n_pp, n2 = n_others, sig.level = 0.05,
             power = 0.8, alternative = "two.sided")

# 3
n <- length(unique(comp_all_7$ID[comp_all_7$Experiment %in% c("Experiment1", "Experiment3", "Experiment4")]))

pwr.chisq.test(N = n, df = 1, sig.level = 0.05, power = 0.8)

# 4
n <- length(unique(comp_all_7$ID[comp_all_7$Experiment %in% c("Experiment1", "Experiment3", "Experiment5")]))

pwr.chisq.test(N = n, df = 1, sig.level = 0.05, power = 0.8)

# 5
pwr.t.test(n = 120, sig.level = 0.05, power = 0.8, type = "paired")


## p. 46, table S20


