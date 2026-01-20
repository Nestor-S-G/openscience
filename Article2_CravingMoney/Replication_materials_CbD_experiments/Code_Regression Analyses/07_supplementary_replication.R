
library(tidyverse)

df <- read.csv("data_220804.csv")

# Remove excluded participants
excluded <- list.files("/excluded_did_not_understand_task")

for(i in 1:length(excluded)) {
  excluded[i] <- str_split(excluded[i], '.xls')[[1]][[1]]
}

df <- df %>%
  filter(!(Sample.ID %in% excluded))

# Add trial and session number
df <- df %>%
  mutate(trial_num = rep(1:20, nrow(df)/20),
         session_number = rep(1:(nrow(df)/20), each = 20)) %>%
  mutate(after_7 = 0, after_8 = 0, after_9 = 0,
         after_7mm = 0, after_8mm = 0, after_9mm = 0)

# Set indices that are after black swan for different criteria
for(i in 1:nrow(df)) {
  if(abs(df$Shot[i]) > 7 & df$Apprentice[i] == 1) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_7[(i+1):max_i] <- 1
  }
  if(abs(df$Shot[i]) > 8 & df$Apprentice[i] == 1) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_8[(i+1):max_i] <- 1
  }
  if(abs(df$Shot[i]) > 9 & df$Apprentice[i] == 1) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_9[(i+1):max_i] <- 1
  }
  if(abs(df$Shot[i]) > 7 & df$Apprentice[i] == 1 & df$Outcome[i] == -40) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_7mm[(i+1):max_i] <- 1
  }
  if(abs(df$Shot[i]) > 8 & df$Apprentice[i] == 1 & df$Outcome[i] == -40) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_8mm[(i+1):max_i] <- 1
  }
  if(abs(df$Shot[i]) > 9 & df$Apprentice[i] == 1 & df$Outcome[i] == -40) {
    max_i <- 20 - df$trial_num[i] + i
    df$after_9mm[(i+1):max_i] <- 1
  }
}


# Calculate if PP and how many sessions
df_pp <- df %>%
  group_by(Sample.ID) %>%
  summarize(pp7 = if_else(sum(Bet[after_7 == 1]) > 1, 1, 0),
            pp8 = if_else(sum(Bet[after_8 == 1]) > 1, 1, 0),
            pp9 = if_else(sum(Bet[after_9 == 1]) > 1, 1, 0),
            pp7mm = if_else(sum(Bet[after_7mm == 1]) > 1, 1, 0),
            pp8mm = if_else(sum(Bet[after_8mm == 1]) > 1, 1, 0),
            pp9mm = if_else(sum(Bet[after_9mm == 1]) > 1, 1, 0),
            n_sesh_7 = length(unique(session_number[Bet == 1 & after_7 == 1])),
            n_sesh_8 = length(unique(session_number[Bet == 1 & after_8 == 1])),
            n_sesh_9 = length(unique(session_number[Bet == 1 & after_9 == 1])),
            n_sesh_7mm = length(unique(session_number[Bet == 1 & after_7mm == 1])),
            n_sesh_8mm = length(unique(session_number[Bet == 1 & after_8mm == 1])),
            n_sesh_9mm = length(unique(session_number[Bet == 1 & after_9mm == 1])))

apply(df_pp[,2:ncol(df_pp)], 2, mean)

apply(df_pp[,2:ncol(df_pp)], 2, sd)

df_pp %>%
  summarize(ses7 = sum(n_sesh_7 > 3)/sum(pp7),
            ses8 = sum(n_sesh_8 > 3)/sum(pp8),
            ses9 = sum(n_sesh_9 > 3)/sum(pp9),
            ses7mm = sum(n_sesh_7mm > 3)/sum(pp7mm),
            ses8mm = sum(n_sesh_8mm > 3)/sum(pp8mm),
            ses9mm = sum(n_sesh_9mm > 3)/sum(pp9mm))


# Accuracy of PP in Bowman questions
df_pp_1 <- df_pp %>%
  filter(pp7 == 1)

df_acc <- df %>%
  filter(Sample.ID %in% df_pp_1$Sample.ID) %>%
  # group_by(Sample.ID) %>%
  summarize(accuracy = sum(Outcome.From.Answer == 10)/sum(Outcome.From.Answer != 0))

# First bet distribution
data_plot <- df %>%
  group_by(Sample.ID) %>%
  mutate(pp7 = if_else(sum(Bet[after_7 == 1]) > 1, 1, 0)) %>%
  ungroup %>%      
  filter(pp7 == 1) %>%
  group_by(Sample.ID, session_number) %>%
  mutate(first_bet = if_else(sum(Bet) < 1, 21.0,
                             as.numeric(trial_num[Bet == 1][1]))) %>%
  slice_head(n = 1) %>%
  ungroup %>%
  mutate(first_bet = factor(first_bet,
                            levels = 1:21,
                            labels = c('1', '2', '3',
                                       '4', '5', '6',
                                       '7', '8', '9',
                                       '10', '11', '12',
                                       '13', '14', '15',
                                       '16', '17', '18',
                                       '19', '20', 'N'))) %>%
  group_by(first_bet) %>%
  summarize(first_bet_dist = n()/630) %>%
  rbind(c('16', 0)) %>%
  mutate(first_bet_dist = as.numeric(first_bet_dist)*100)

ggplot(data_plot, aes(first_bet, first_bet_dist)) +
  geom_bar(stat = 'identity', fill = '#2b28b8') +
  labs(x = 'First time subject chose bet action within a session (trial #)',
       y = 'Frequency (%)',
       title = 'ACTUAL PENNY PICKERS') +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5,
                                  size = 16),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggsave('brown_firstbet_distribution.png', width = 10, height = 6)


# Never bet before 3rd

df_start <- df %>%
  group_by(Sample.ID) %>%
  mutate(pp7 = if_else(sum(Bet[after_7 == 1]) > 1, 1, 0)) %>%
  ungroup %>%      
  filter(pp7 == 1) %>%
  group_by(Sample.ID, session_number) %>%
  mutate(first_bet = if_else(sum(Bet) < 1, 21.0,
                             as.numeric(trial_num[Bet == 1][1]))) %>%
  slice_head(n = 1) %>%
  group_by(Sample.ID) %>%
  summarize(before_1 = if_else(sum(first_bet < 1) == 0, 1, 0),
            before_2 = if_else(sum(first_bet < 2) == 0, 1, 0),
            before_3 = if_else(sum(first_bet < 3) == 0, 1, 0),
            before_4 = if_else(sum(first_bet < 4) == 0, 1, 0),
            before_5 = if_else(sum(first_bet < 5) == 0, 1, 0),
            before_6 = if_else(sum(first_bet < 6) == 0, 1, 0),
            before_7 = if_else(sum(first_bet < 7) == 0, 1, 0),
            before_8 = if_else(sum(first_bet < 8) == 0, 1, 0),
            before_9 = if_else(sum(first_bet < 9) == 0, 1, 0),
            before_10 = if_else(sum(first_bet < 10) == 0, 1, 0),
            before_11 = if_else(sum(first_bet < 11) == 0, 1, 0))

apply(df_start[,2:ncol(df_start)], 2, mean)


# First bet never after
df_start <- df %>%
  group_by(Sample.ID) %>%
  mutate(pp8 = if_else(sum(Bet[after_8 == 1]) > 1, 1, 0)) %>%
  ungroup %>%
  filter(pp8 == 1) %>%
  group_by(Sample.ID, session_number) %>%
  mutate(first_bet = if_else(sum(Bet) < 1, 21.0,
                             as.numeric(trial_num[Bet == 1][1]))) %>%
  slice_head(n = 1) %>%
  group_by(Sample.ID) %>%
  summarize(all_after_1 = if_else(sum(first_bet < 2) == 0, 1, 0),
            all_after_2 = if_else(sum(first_bet < 3) == 0, 1, 0),
            all_after_3 = if_else(sum(first_bet < 4) == 0, 1, 0),
            all_after_4 = if_else(sum(first_bet < 5) == 0, 1, 0),
            all_after_5 = if_else(sum(first_bet < 6) == 0, 1, 0),
            all_after_6 = if_else(sum(first_bet < 7) == 0, 1, 0),
            all_after_7 = if_else(sum(first_bet < 8) == 0, 1, 0),
            all_after_8 = if_else(sum(first_bet < 9) == 0, 1, 0),
            all_after_9 = if_else(sum(first_bet < 10) == 0, 1, 0),
            all_after_10 = if_else(sum(first_bet < 11) == 0, 1, 0),
            all_after_11 = if_else(sum(first_bet < 12) == 0, 1, 0))

apply(df_start[,2:ncol(df_start)], 2, mean)



