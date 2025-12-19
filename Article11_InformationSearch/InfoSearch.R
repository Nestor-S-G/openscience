# 1. Load necessary libraries
library(tidyverse)
library(lme4)      # For Mixed-Effects Models (Cluster Regression)
library(lmerTest)  # To get p-values for lmer models
library(broom)     # To tidy model outputs
library(readxl)

# 2. Load the data
# Ensure the file is in your working directory
data <- read_excel("Interplay_IS_CE_Data.xls", sheet = 1)

# 3. Data Cleaning & Preparation
# The paper analyzes 'guilt' (final judgment) and 'hrate' (evidence evaluation)
# Scale the guilt variable if necessary (Check paper for 0-100 vs -100 to 100)
data_clean <- data %>%
  filter(!is.na(guilt), !is.na(hrate)) %>%
  mutate(
    study = as.factor(study),
    case = as.factor(case),
    bedingung = as.factor(bedingung), # Condition
    # Center variables for better interpretation in regression
    hrate_centered = hrate - mean(hrate, na.rm = TRUE)
  )

# --- REPRODUCTION 1: The Coherence Effect ---
# The paper argues that evidence evaluation (hrate) is shifted to be 
# consistent with the final decision (guilt).

cat("### Running Analysis for Coherence Effects ###\n")

# Model: hrate ~ guilt + (1 | username_new)
# This tests if the evaluation of a piece of evidence is predicted by the final guilt rating
coherence_model <- lmer(hrate ~ guilt + (1 | username_new) + (1 | case), data = data_clean)
summary(coherence_model)

# --- REPRODUCTION 2: Selective/Confirmatory Search ---
# Checking if 'signchosenevidence' (the valence of the chosen piece) 
# is predicted by the current belief (guilt).

cat("\n### Running Analysis for Information Search (Confirmatory Bias) ###\n")

# Model: signchosenevidence ~ guilt + (1 | username_new)
search_model <- lmer(signchosenevidence ~ guilt + (1 | username_new), data = data_clean)
summary(search_model)

# --- REPRODUCTION 3: Comparing Conditions (Study 4) ---
# Testing if the "No Strategic Search" condition (from your .boxs file) 
# reduced the bias compared to the free search.

study4_data <- data_clean %>% filter(study == 4)

comparison_model <- lmer(hrate ~ guilt * bedingung + (1 | username_new), data = study4_data)
summary(comparison_model)

# 4. Visualization (Standard Plot in the Paper)
# Visualizing the relationship between final guilt and evidence rating
ggplot(data_clean, aes(x = guilt, y = hrate)) +
  geom_jitter(alpha = 0.1, color = "gray") +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Coherence Effect: Evidence Rating vs. Final Guilt",
       x = "Final Guilt Rating (Judgment)",
       y = "Individual Evidence Evaluation (hrate)") +
  theme_minimal()