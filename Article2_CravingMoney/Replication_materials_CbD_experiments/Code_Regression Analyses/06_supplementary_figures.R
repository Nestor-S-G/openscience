library(tidyverse)

## p. 14, figure S1

# Panel A
data_plot_S1a <- comp_all_7 %>%
  filter(Apprentice == 1 & Experiment %in% c("Experiment1",
                                            "Expriment3",
                                            "Experiment4",
                                            "Experiment5")) %>%
  mutate(exposure_time = NA)

e_time <- 0
theta <- 1
for (i in 1:nrow(data_plot_S1a)) {
  
  # If exposure time is 0, assign zero
  # Else assign craving variable
  if (e_time == 0) {
    data_plot_S1a$exposure_time[i] <- 0
  } else {
    # Previous outcomes
    out_hist <- if_else(data_plot_S1a$Outcome[(i-e_time):(i-1)] > 0, 1, 0)
    
    data_plot_S1a$exposure_time[i] <- sum(out_hist*theta^((e_time-1):0))
  }
  
  # Reset if new sequence
  if(i != nrow(data_plot_S1a)) {
    if (data_plot_S1a$Session_Number[i+1] != data_plot_S1a$Session_Number[i]) {
      e_time <- 0
    } else {
      e_time <- e_time + 1
    }
  }
}

data_plot_S1a_out <- data_plot_S1a %>%
  mutate(exp_bins = as.numeric(cut_interval(exposure_time, 5)),
         exp_num = cut_interval(exposure_time, 5)) %>%
  group_by(exp_bins, ID) %>%
  summarize(betting_rate = mean(Bet)) %>%
  ungroup %>%
  group_by(exp_bins) %>%
  summarize(se = se(betting_rate),
            betting_rate = mean(betting_rate, na.rm = TRUE)) %>%
  ungroup

ggplot(data_plot_S1a_out, aes(x = exp_bins, y = betting_rate)) +
  geom_line(color = '#1980DD') +
  geom_errorbar(aes(ymin = betting_rate - se,
                    ymax = betting_rate + se),
                width = 0.2, color = '#1980DD',
                alpha = 0.5) +
  labs(x = 'Reward exposure',
       y = 'Betting rate with apprentice') +
  scale_x_continuous(breaks = 1:5) +
  scale_y_continuous(limits = c(0.05, 1)) +
  theme_minimal()

# Panel B
exp_2_fig_7_split_out <- comp_all_7 %>%
  filter(Apprentice == 1 & PP == 1 & Experiment %in% c("Experiment1",
                                                       "Expriment3",
                                                       "Experiment4",
                                                       "Experiment5")) %>%
  group_by(ID, Session_Number) %>%
  mutate(did_bet = if_else(sum(Bet) > 0, 1, 0)) %>%
  ungroup %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  group_by(ID) %>%
  summarize(med_first_bet = mean(first_bet)) %>%
  ungroup %>%
  mutate(dist_first_bet = if_else(med_first_bet < 3, '<3',
                                  if_else(med_first_bet < 7, '3-6',
                                          if_else(med_first_bet < 11, '7-10', '>10'))),
         dist_first_bet = factor(dist_first_bet, levels = c('<3', '3-6', '7-10', '>10'))) %>%
  count(dist_first_bet, name = 'n', .drop = F) %>%
  mutate(freq = (n/sum(n))*100)

ggplot(exp_2_fig_7_split_out, aes(x = dist_first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  scale_y_continuous(name = 'Frequency (%)') +
  scale_x_discrete(name = 'First time subject choose\naction Bet in session (trial #)') +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 24),
        axis.text = element_text(size = 24))


## p. 15, figure S2
exp_2_fig_7_split <- comp_all_7 %>%
  filter(Experiment == 'Experiment2') %>%
  group_by(ID, Session_Number, Apprentice) %>%
  mutate(did_bet = if_else(sum(Bet) > 0, 1, 0))

exp_2_fig_7_split_0 <- exp_2_fig_7_split %>%
  filter(did_bet == 0) %>%
  group_by(ID, Session_Number, Apprentice, PP) %>%
  summarize(first_bet = 22) %>%
  ungroup

exp_2_fig_7_split_out <- exp_2_fig_7_split %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number, Apprentice, PP) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  rbind(exp_2_fig_7_split_0) %>%
  group_by(first_bet, Apprentice, PP) %>%
  summarize(n = n()) %>%
  group_by(Apprentice, PP) %>%
  mutate(freq = (n/sum(n))*100) %>%
  ungroup %>%
  mutate(PP = factor(PP, levels = 1:0, labels = c("PP", "Others")),
         Apprentice = factor(Apprentice, levels = 0:1,
                             labels = c("Master", "Apprentice")))

ggplot(exp_2_fig_7_split_out, aes(x = first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  geom_vline(xintercept = 21, linetype = "dashed", 
             color = "gray", size = 1) +
  scale_y_continuous(name = 'Frequency (%)') +
  scale_x_continuous(name = 'First time subject chose\naction Bet in session (trial #)',
                     breaks = c(1, 5, 10, 15, 20, 22), labels = c('1', '5',
                                                                  '10', '15',
                                                                  '20', 'N')) +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 24),
        axis.text = element_text(size = 24),
        strip.text = element_text(size = 24),
        panel.background = element_rect(fill = NA, color = "black")) +
  facet_grid(c("Apprentice", "PP"), scales = 'free_y', drop = FALSE)


## p. 16, figure S3
exp_1345_fig_7_split <- comp_all_7 %>%
  filter(Experiment %in% c('Experiment1', 'Experiment3',
                           'Experiment4', 'Experiment5')) %>%
  group_by(ID, Session_Number, Apprentice) %>%
  mutate(did_bet = if_else(sum(Bet) > 0, 1, 0))

exp_1345_fig_7_split_0 <- exp_1345_fig_7_split %>%
  filter(did_bet == 0) %>%
  group_by(ID, Session_Number, Apprentice, PP) %>%
  summarize(first_bet = 22) %>%
  ungroup

exp_1345_fig_7_split_out <- exp_1345_fig_7_split %>%
  filter(did_bet == 1) %>%
  group_by(ID, Session_Number, Apprentice, PP) %>%
  summarize(first_bet = min(Trial[Bet == 1])) %>%
  rbind(exp_1345_fig_7_split_0) %>%
  group_by(first_bet, Apprentice, PP) %>%
  summarize(n = n()) %>%
  group_by(Apprentice, PP) %>%
  mutate(freq = (n/sum(n))*100) %>%
  ungroup %>%
  mutate(PP = factor(PP, levels = 1:0, labels = c("PP", "Others")),
         Apprentice = factor(Apprentice, levels = 0:1,
                             labels = c("Master", "Apprentice")))

ggplot(exp_1345_fig_7_split_out, aes(x = first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  geom_vline(xintercept = 21, linetype = "dashed", 
             color = "gray", size = 1) +
  scale_y_continuous(name = 'Frequency (%)') +
  scale_x_continuous(name = 'First time subject chose\naction Bet in session (trial #)',
                     breaks = c(1, 5, 10, 15, 20, 22), labels = c('1', '5',
                                                                  '10', '15',
                                                                  '20', 'N')) +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 24),
        axis.text = element_text(size = 24),
        strip.text = element_text(size = 26),
        panel.background = element_rect(fill = NA, color = 'black')) +
  facet_grid(c("Apprentice", "PP"), scales = 'free_y')


## p. 17, figure S4
exp_2 <- comp_all_7 %>%
  filter(Experiment == 'Experiment2' & Apprentice == 1 & PP == 1)

exp_2_random_001 <- exp_2
exp_2_random_080 <- exp_2

exp_2_random_001$Bet <- rbinom(nrow(exp_2_random_001), 1, 0.01)
exp_2_random_080$Bet <- rbinom(nrow(exp_2_random_080), 1, 0.80)

exp_2_random_080 <- exp_2_random_080 %>%
  group_by(ID) %>%
  mutate(PP = if_else(sum(Bet[Apprentice == 1]) > 1, 1, 0)) %>%
  ungroup

exp_2_random_001 <- exp_2_random_001 %>%
  group_by(ID) %>%
  mutate(PP = if_else(sum(Bet[Apprentice == 1]) > 1, 1, 0)) %>%
  ungroup

exp_2_random_080_first <- exp_2_random_080 %>%
  group_by(ID, Session_Number, Apprentice) %>%
  summarize(first_bet = if_else(sum(Bet) > 0, min(Trial[Bet == 1]), 22)) %>%
  group_by(first_bet) %>%
  summarize(n = n()) %>%
  ungroup %>%
  mutate(freq = (n/sum(n))*100,
         prob = 'A')

exp_2_random_001_first <- exp_2_random_001 %>%
  group_by(ID, Session_Number, Apprentice) %>%
  summarize(first_bet = if_else(sum(Bet) > 0, min(Trial[Bet == 1]), 22)) %>%
  group_by(first_bet) %>%
  summarize(n = n()) %>%
  ungroup %>%
  mutate(freq = (n/sum(n))*100,
         prob = 'B')

exp_2_first <- exp_2 %>%
  filter(PP == 1) %>%
  group_by(ID, Session_Number, Apprentice) %>%
  summarize(first_bet = if_else(sum(Bet) > 0, min(Trial[Bet == 1]), 22)) %>%
  group_by(first_bet) %>%
  summarize(n = n()) %>%
  ungroup %>%
  mutate(freq = n/sum(n)*100,
         prob = 'C')

ggplot(exp_2_random_080_first, aes(x = first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  geom_vline(xintercept = 21, linetype = "dashed", 
             color = "gray", size = 1) +
  scale_y_continuous(name = 'Frequency (%)', limits = c(0, 90),
                     breaks = c(0, 20, 40, 60, 80)) +
  scale_x_continuous(name = 'First time subject chose\naction Bet in session (trial #)',
                     breaks = c(1, 5, 10, 15, 20, 22), labels = c('1', '5',
                                                                  '10', '15',
                                                                  '20', 'N')) +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 26),
        axis.text = element_text(size = 26))


ggplot(exp_2_random_001_first, aes(x = first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  geom_vline(xintercept = 21, linetype = "dashed", 
             color = "gray", size = 1) +
  scale_y_continuous(name = 'Frequency (%)', limits = c(0, 90),
                     breaks = c(0, 20, 40, 60, 80)) +
  scale_x_continuous(name = 'First time subject chose\naction Bet in session (trial #)',
                     breaks = c(1, 5, 10, 15, 20, 22), labels = c('1', '5',
                                                                  '10', '15',
                                                                  '20', 'N')) +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 26),
        axis.text = element_text(size = 26))

ggplot(exp_2_first, aes(x = first_bet, y = freq)) +
  geom_bar(stat='identity', color = 'black', fill = 'blue') +
  geom_vline(xintercept = 21, linetype = "dashed", 
             color = "gray", size = 1) +
  scale_y_continuous(name = 'Frequency (%)', limits = c(0, 90),
                     breaks = c(0, 20, 40, 60, 80)) +
  scale_x_continuous(name = 'First time subject chose\naction Bet in session (trial #)',
                     breaks = c(1, 5, 10, 15, 20, 22), labels = c('1', '5',
                                                                  '10', '15',
                                                                  '20', 'N')) +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 26),
        axis.text = element_text(size = 26))


