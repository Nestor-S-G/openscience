# 1. Load necessary libraries
library(tidyverse)
library(lme4)
library(lmerTest)
library(readxl)

# 2. Advanced Data Preparation
data <- read_excel("Interplay_IS_CE_Data.xls")

data_clean <- data %>%
  # Remove rows with missing values in core variables
  filter(!is.na(guilt), !is.na(hrate), !is.na(signchosenevidence)) %>%
  # Order data to calculate search sequence accurately
  arrange(username_new, case, evidencenr) %>%
  group_by(username_new, case) %>%
  mutate(
    # --- URN MODEL: INFORMATION AVAILABILITY ---
    # Tracking how many pro-guilty (+1) and contra-guilty (-1) items were already picked
    pro_chosen = lag(cumsum(ifelse(signchosenevidence == 1, 1, 0)), default = 0),
    contra_chosen = lag(cumsum(ifelse(signchosenevidence == -1, 1, 0)), default = 0),
    # Difference in available pieces (Assuming a pool of 6 vs 6 per case)
    available_diff = (6 - pro_chosen) - (6 - contra_chosen),
    
    # --- VARIABLE SCALING ---
    # The paper uses hrate from -5 to 5. 
    # If your raw 'hrate' is 0 to 1, we rescale it to match paper magnitudes.
    hrate_rescaled = (hrate * 10) - 5, 
    guilt_01 = guilt # Already 0 to 1
  ) %>%
  ungroup() %>%
  mutate(
    # Ensure condition 1 is the 'Systematic Search' reference
    bedingung = factor(bedingung, levels = c(2, 1), labels = c("Non-Systematic", "Systematic")),
    study = as.factor(study),
    case = as.factor(case)
  )

# --- HYPOTHESIS 1: Information Search (The "Confirmation Bias" test) ---
# Testing if prior guilt predicts the sign of the chosen evidence
# Paper focuses on the Systematic Condition for this test
cat("\n### H1: Information Search (Sign of Chosen Evidence) ###\n")
h1_model <- lmer(signchosenevidence ~ guilt_01 + available_diff + (1 | username_new) + (1 | case), 
                 data = subset(data_clean, bedingung == "Systematic"))
summary(h1_model)

# --- HYPOTHESIS 2: Coherence Effects (Evaluation Bias) ---
# Testing if prior guilt predicts the evaluation of the piece of evidence (hrate)
cat("\n### H2: Coherence Effects (Evidence Evaluation) ###\n")
h2_model <- lmer(hrate_rescaled ~ guilt_01 * as.factor(signchosenevidence) + (1 | username_new) + (1 | case), 
                 data = data_clean)
summary(h2_model)

# --- HYPOTHESIS 3: Interplay (Intervention Effect) ---
# Does systematic search reduce or increase the coherence effect?
cat("\n### H3: Interplay (Condition * Guilt Interaction) ###\n")
h3_model <- lmer(hrate_rescaled ~ guilt_01 * bedingung + (1 | username_new) + (1 | case), 
                 data = data_clean)
summary(h3_model)
