# 1. Load libraries
library(tidyverse)
library(lme4)
library(lmerTest)
library(readxl)

# 2. Data Preparation & Scaling
data <- read_excel("Interplay_IS_CE_Data.xls")

data_clean <- data %>%
  # IMPORTANT: Use 'guilt1' (Initial Guilt) as the predictor of bias
  # The paper tests how INITIAL beliefs bias subsequent search and evaluation.
  filter(!is.na(guilt1), !is.na(hrate), !is.na(signchosenevidence)) %>%
  arrange(username_new, case, evidencenr) %>%
  group_by(username_new, case) %>%
  mutate(
    # --- URN MODEL (Information Availability) ---
    pro_chosen = lag(cumsum(ifelse(signchosenevidence == 1, 1, 0)), default = 0),
    contra_chosen = lag(cumsum(ifelse(signchosenevidence == -1, 1, 0)), default = 0),
    pro_avail = 6 - pro_chosen,
    contra_avail = 6 - contra_chosen,
    
    # Availability difference relative to initial leaning (as per paper logic)
    # If guilt1 > 0.5 (pro-guilty leaning), diff = pro - contra
    # If guilt1 <= 0.5 (pro-innocence leaning), diff = contra - pro
    avail_diff_paper = ifelse(guilt1 > 0.5, pro_avail - contra_avail, contra_avail - pro_avail),
    
    # --- SEARCH DIRECTION (Confirmation Index) ---
    # 1 = Picked evidence matching leaning, -1 = Picked evidence opposite to leaning
    search_dir = ifelse(guilt1 > 0.5, signchosenevidence, -signchosenevidence)
  ) %>%
  ungroup() %>%
  mutate(
    # --- SCALING TO MATCH PAPER MAGNITUDES ---
    # Scale hrate from 0-1 to the -5 to 5 range used in the paper
    hrate_rescaled = (hrate * 10) - 5,
    # Condition mapping: 1 = Systematic, 2 = Control
    condition = factor(bedingung, levels = c(2, 1), labels = c("Control", "Systematic"))
  )

# --- HYPOTHESIS 1: Information Search (Disconfirmatory Search) ---
# Paper reports b = -0.24. A negative intercept/coefficient here indicates 
# a preference for disconfirmatory information.
cat("\n### H1: Information Search (Dependent Variable: Search Direction) ###\n")
h1_model <- lmer(search_dir ~ guilt1 + avail_diff_paper + (1 | username_new) + (1 | case), 
                 data = subset(data_clean, bedingung == 1))
summary(h1_model)

# --- HYPOTHESIS 2: Coherence Effects (Evaluation Bias) ---
# Paper reports b = 0.40. This tests how much guilt1 predicts hrate.
cat("\n### H2: Coherence Effects (Evidence Evaluation) ###\n")
h2_model <- lmer(hrate_rescaled ~ guilt1 * signchosenevidence + (1 | username_new) + (1 | case), 
                 data = data_clean)
summary(h2_model)

# --- HYPOTHESIS 3: Interplay (Interaction) ---
# Paper reports interaction is NOT significant (b = 0.04).
cat("\n### H3: Interplay (Condition * Initial Guilt) ###\n")
h3_model <- lmer(hrate_rescaled ~ guilt1 * condition + (1 | username_new) + (1 | case), 
                 data = data_clean)
summary(h3_model)
