library(tidyverse)

se <- function (x) {
  se = sd(x, na.rm = TRUE)/sqrt(length(x))
  return(se)
}

## p. 26, Figure 5 A-D


## 5A
## Avg betting rate w/ apprentice by session number
data_plot_5a <- comp_all_7 %>%
  filter(Apprentice == 1 & PP == 1 &
           Experiment != "sessions_with_MBA_students") %>%
  group_by(Session_Number, ID) %>%
  summarize(betting_rate = mean(Bet)) %>%
  group_by(Session_Number) %>%
  summarize(se = se(betting_rate),
            betting_rate = mean(betting_rate))


ggplot(data_plot_5a, aes(x = Session_Number, y = betting_rate)) +
  geom_line() +
  geom_errorbar(aes(ymin = betting_rate - se, ymax = betting_rate + se)) +
  labs(x = 'Session number',
       y = 'Average betting rate with apprentice') +
  theme_minimal()


## 5B
data_plot_5b <- comp_all_7 %>%
  filter(Apprentice == 1 & Experiment == "Experiment2") %>%
  mutate(exposure_time = NA)

e_time <- 0
theta <- 1
for (i in 1:nrow(data_plot_5b)) {
  
  # If exposure time is 0, assign zero
  # Else assign craving variable
  if (e_time == 0) {
    data_plot_5b$exposure_time[i] <- 0
  } else {
    # Previous outcomes
    out_hist <- if_else(data_plot_5b$Outcome[(i-e_time):(i-1)] > 0, 1, 0)
    
    data_plot_5b$exposure_time[i] <- sum(out_hist*theta^((e_time-1):0))
  }
  
  # Reset if new sequence
  if(i != nrow(data_plot_5b)) {
    if (data_plot_5b$Session_Number[i+1] != data_plot_5b$Session_Number[i]) {
      e_time <- 0
    } else {
      e_time <- e_time + 1
    }
  }
}

data_plot_5b_out <- data_plot_5b %>%
  mutate(exp_bins = as.numeric(cut_interval(exposure_time, 5)),
         exp_num = cut_interval(exposure_time, 5)) %>%
  group_by(exp_bins, ID) %>%
  summarize(betting_rate = mean(Bet)) %>%
  ungroup %>%
  group_by(exp_bins) %>%
  summarize(se = se(betting_rate),
            betting_rate = mean(betting_rate, na.rm = TRUE)) %>%
  ungroup

ggplot(data_plot_5b_out, aes(x = exp_bins, y = betting_rate)) +
  geom_line(color = '#1980DD') +
  geom_errorbar(aes(ymin = betting_rate - se,
                    ymax = betting_rate + se),
                width = 0.2, color = '#1980DD',
                alpha = 0.5) +
  labs(x = 'Reward exposure',
       y = 'Betting rate with apprentice') +
  scale_x_continuous(breaks = 1:5) +
  theme_minimal()

## 5C
exp_2_fig_7_split_out <- comp_all_7 %>%
  filter(Experiment == 'Experiment2' & Apprentice == 1 & PP == 1) %>%
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

## 5D
plot_prop_pp_by_exp <- comp_all_8mm %>%
  filter(Experiment %in% c('Experiment1', 'Experiment3', 'Experiment4')) %>%
  mutate(exp_group = if_else(Experiment == 'Experiment4', 'Experiment4', 'Experiment13')) %>%
  group_by(ID) %>%
  slice_head(n = 1) %>%
  group_by(exp_group) %>%
  summarize(prop_pp = mean(PP)) %>%
  ungroup

ggplot(plot_prop_pp_by_exp, aes(x = exp_group, y = prop_pp)) +
  geom_bar(stat = 'identity', color = 'black', fill = '#162191',
           width = 0.6) +
  scale_x_discrete(name = '', breaks = c('Experiment13', 'Experiment4'),
                   labels = c('Without\ncommitment\ndevice',
                              'With\ncommitment\ndevice')) +
  scale_y_continuous(name = 'Proportion of penny pickers') +
  theme_minimal() +
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.title = element_text(size = 25),
        axis.text = element_text(size = 22))

