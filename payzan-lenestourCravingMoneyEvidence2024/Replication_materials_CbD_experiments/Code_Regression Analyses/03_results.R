library(tidyverse)
library(pwr)

# Mode function
Modes <- function(x) {
  ux <- unique(x)
  tab <- tabulate(match(x, ux))
  ux[tab == max(tab)]
}


## p. 24, table 1 - Prevalence of the picking pennies bias in each experiment
pp_prevalence_24 <- comp_all_7 %>%
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

pp_by_n_session_24 <- comp_all_7 %>%
  filter(Experiment %in% c("Experiment1",
                           "Experiment2",
                           "Experiment3",
                           "Experiment4",
                           "Experiment5") &
           Apprentice == 1 & PP == 1) %>%
  group_by(ID, Session_Number) %>%
  slice_head(n = 1) %>%
  group_by(ID, Experiment) %>%
  summarize(n_sessions_pp = sum(PP_By_Session)) %>%
  ungroup

# At least 2, 3, 4
pp_by_n_session_24 %>%
  group_by(Experiment) %>%
  summarize(atleast_2 = sum(n_sessions_pp > 1)/n(),
            atleast_3 = sum(n_sessions_pp > 2)/n(),
            atleast_4 = sum(n_sessions_pp > 3)/n())

# Mean, SD N sessions PP by exp
pp_by_n_session_24 %>%
  group_by(Experiment) %>%
  summarize(mean = mean(n_sessions_pp),
            sd = sd(n_sessions_pp))


## p. 25, chi-sq - PP prevalence exp 1,3,5 vs 2
prop_test_25 <- comp_all_7 %>%
  filter(Experiment %in% c("Experiment1",
                           "Experiment2",
                           "Experiment3",
                           "Experiment5")) %>%
  mutate(grouping = if_else(Experiment == "Experiment2", 1, 0)) %>%
  group_by(ID) %>%
  slice_head(n = 1) %>%
  ungroup

prop.test(table(prop_test_25$PP, prop_test_25$grouping))


## p. 25, two-sample t-test - accuracy PP/Others
t_test_p25 <- comp_all_9mm %>%
  filter(Experiment %in% c("Experiment3", "Experiment5")) %>%
  drop_na(Guess) %>%
  group_by(PP, ID) %>%
  summarize(accuracy = sum(Guess == Apprentice)/n()) %>%
  ungroup

t.test(accuracy ~ PP, data = t_test_p25, var.equal = TRUE)

sum(mean(t_test_p25$accuracy[t_test_p25$PP == 0]) - mean(t_test_p25$accuracy[t_test_p25$PP == 1]))/
  sqrt((sd(t_test_p25$accuracy[t_test_p25$PP == 0])^2 + sd(t_test_p25$accuracy[t_test_p25$PP == 1])^2)/
         2)

pwr.t2n.test(n1 = 34, n2 = 65, d = 0.8)

pwr.t2n.test(n1 = 34, n2 = 65, sig.level = 0.05, power = 0.8)


## p. 27, chi-sq -  proportion PP exp 4 vs 1,3
chisq_p27_1 <- comp_all_7 %>%
  group_by(ID) %>%
  slice_head(n = 1) %>%
  ungroup %>%
  filter(Experiment %in% c("Experiment1", "Experiment3", "Experiment4")) %>%
  mutate(grouping = if_else(Experiment == "Experiment4", 1, 0))

results_p27_1 <- prop.test(table(chisq_p27_1$PP, chisq_p27_1$grouping))
results_p27_1

v_p27_1 = sqrt((results_p27_1$statistic/nrow(chisq_p27_1))/1)
v_p27_1


## p. 27, chi-sq - prop PP exp 5 vs 1,3
chisq_p27_2 <- comp_all_7 %>%
  group_by(ID) %>%
  slice_head(n = 1) %>%
  ungroup %>%
  filter(Experiment %in% c("Experiment1", "Experiment3", "Experiment5")) %>%
  mutate(grouping = if_else(Experiment == "Experiment5", 1, 0))

results_p27_2 <- prop.test(table(chisq_p27_2$PP, chisq_p27_2$grouping))
results_p27_2

v_p27_2 = sqrt((results_p27_2$statistic/nrow(chisq_p27_2))/1)
v_p27_2


## p. 28, t-test - betting rates PP/others with bowman exp 1,3,5
t_test_p28 <- comp_all_7mm %>%
  filter(Experiment %in% c("Experiment1", "Experiment3", "Experiment5") &
           Apprentice == 0) %>%
  group_by(ID, PP) %>%
  summarize(betting_rate = mean(Bet)) %>%
  ungroup

t.test(betting_rate ~ PP, data = t_test_p28)

sum(mean(t_test_p28$betting_rate[t_test_p28$PP == 0]) - mean(t_test_p28$betting_rate[t_test_p28$PP == 1]))/
  sqrt((sd(t_test_p28$betting_rate[t_test_p28$PP == 0])^2 + sd(t_test_p28$betting_rate[t_test_p28$PP == 1])^2)/
         2)

pwr.t2n.test(n1 = 90, n2 = 133, d = 0.8)

pwr.t2n.test(n1 = 90, n2 = 133, sig.level = 0.05, power = 0.8)

