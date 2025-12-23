# Load libraries
library(haven)
library(dplyr)
library(tidyr)
library(broom) # For tidy model outputs

# 1. Unified Data Loading and Cleaning
files <- c("GAMU_DATA_00.dta", "GAMU_DATA_01.dta", "GAMU_DATA_02.dta", "GAMU_DATA_03.dta")
raw_full <- bind_rows(lapply(files, read_dta))

# Aggregate to subject-session level to handle trial-level data duplication
clean_data <- raw_full %>%
  group_by(UniID, Session) %>%
  summarise(
    # Core Behavioral Outcomes
    Risk_BRET = mean(BRETchoice, na.rm = TRUE),
    Exploration_Tree = mean(Tree_n, na.rm = TRUE),
    Cheating_Dice = mean(DiceRoll_A, na.rm = TRUE),
    # Treatment and Demographics
    Treatment = first(na.omit(Treatment)),
    is_female = first(na.omit(female)),
    # Salivary Hormones
    Progesterone = mean(Progesterone, na.rm = TRUE),
    Estradiol = mean(Estradiol, na.rm = TRUE),
    Cortisol = mean(Cortisol, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Cycle_Phase = case_when(
    Treatment == 0 ~ "Male Control",
    (Treatment == 1021 & Session == 1) | (Treatment == 1120 & Session == 2) ~ "Ovulation",
    (Treatment == 1021 & Session == 2) | (Treatment == 1120 & Session == 1) ~ "Menstruation",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(Cycle_Phase))

# 2. Within-Subject Comparison (Paired Wilcoxon Tests)
# The paper suggests non-parametric tests for within-subject comparisons
compare_phases <- function(var_name) {
  df_wide <- clean_data %>%
    filter(is_female == 1, Cycle_Phase %in% c("Ovulation", "Menstruation")) %>%
    select(UniID, Cycle_Phase, !!sym(var_name)) %>%
    pivot_wider(names_from = Cycle_Phase, values_from = !!sym(var_name)) %>%
    drop_na()
  
  test <- wilcox.test(df_wide$Ovulation, df_wide$Menstruation, paired = TRUE)
  return(test)
}

cat("--- Non-Parametric Within-Subject Results ---\n")
print(list(
  Risk = compare_phases("Risk_BRET"),
  Exploration = compare_phases("Exploration_Tree"),
  Cheating = compare_phases("Cheating_Dice")
))

# 3. Hormonal Regression Model
# This checks if specific hormone levels (rather than just the phase) drive behavior
cat("\n--- Hormonal Regression (Risk ~ Progesterone + Estradiol) ---\n")
hormone_reg <- lm(Risk_BRET ~ Progesterone + Estradiol + Cortisol, 
                  data = clean_data %>% filter(is_female == 1))
summary(hormone_reg)

# 4. Visualization of Results
library(ggplot2)
ggplot(clean_data %>% filter(is_female == 1), aes(x = Cycle_Phase, y = Exploration_Tree, fill = Cycle_Phase)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Exploration Attitude (Apple Tree Task) by Cycle Phase",
       y = "Number of Trees Harvested", x = "")