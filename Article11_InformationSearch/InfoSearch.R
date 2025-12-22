# 1. Load necessary libraries
library(tidyverse)
library(lme4)  # For Mixed-Effects Models
library(lmerTest)  # To get p-values for lmer models
library(broom)  # To tidy model outputs
library(readxl)
library(emmeans)  # For post-hoc contrasts

# 2. Load the data
data <- read_excel("Interplay_IS_CE_Data.xls", sheet = "Sheet1")

# 3. Data Cleaning & Preparation
data_clean <- data %>%
  filter(!is.na(guilt), !is.na(hrate), !is.na(signchosenevidence)) %>%
  mutate(
    study = as.factor(study),
    case = as.factor(case),
    bedingung = as.factor(bedingung),  # Condition: 1=non-systematic, 2=systematic?
    # Scale guilt to 0-1 (max=100 from data)
    guilt_scaled = guilt,
    # Valence from signchosenevidence (pro-guilty=1, neutral=0, contra-guilty=-1)
    valence = as.factor(ifelse(signchosenevidence > 0, "pro-guilty", ifelse(signchosenevidence == 0, "neutral", "contra-guilty"))),
    # Phase from evidencenr (position)
    phase = cut(evidencenr, breaks = c(0, 4, 7, Inf), labels = c("early", "mid", "late")),
    # Center hrate
    hrate_centered = hrate - mean(hrate, na.rm = TRUE),
    # Reverse signchosenevidence for disconfirmatory (higher guilt -> lower/negative)
    signchosenevidence_rev = -signchosenevidence,
    # Content from chosenevidence
    content = as.factor(chosenevidence)
  )

# --- REPRODUCTION 1: Coherence Effects (with valence moderation) ---
cat("### Coherence Effects (Base and with Valence) ###\n")
coherence_base <- lmer(hrate ~ guilt_scaled + (1 | username_new) + (1 | case), data = data_clean)
summary(coherence_base)

coherence_valence <- lmer(hrate ~ guilt_scaled * valence + (1 | username_new) + (1 | case), data = data_clean)
summary(coherence_valence)
emmeans(coherence_valence, pairwise ~ valence | guilt_scaled, at = list(guilt_scaled = c(0,1)))

# --- REPRODUCTION 2: Information Search (with covariates and phase) ---
cat("\n### Information Search (Base, with Covariates, by Phase) ###\n")
search_base <- lmer(signchosenevidence_rev ~ guilt_scaled + (1 | username_new), data = data_clean)
summary(search_base)

search_cov <- lmer(signchosenevidence_rev ~ guilt_scaled + evidencenr + content + (1 | username_new), data = data_clean)
summary(search_cov)

search_phase <- lmer(signchosenevidence_rev ~ guilt_scaled * phase + (1 | username_new), data = data_clean)
summary(search_phase)
emmeans(search_phase, pairwise ~ phase | guilt_scaled, at = list(guilt_scaled = c(0,1)))

# --- REPRODUCTION 3: Condition Comparison (with valence, across studies) ---
cat("\n### Condition Comparison (with Valence, Across Studies) ###\n")
comparison_full <- lmer(hrate ~ guilt_scaled * bedingung * valence + (1 | username_new) + (1 | case) + (1 | study), data = data_clean)
summary(comparison_full)
emmeans(comparison_full, pairwise ~ bedingung * valence | guilt_scaled, at = list(guilt_scaled = c(0,1)))

# --- Robustness / Appendix: Add Controls (NFC=pfc, CRT=crt_total, BIS/BAS=hh/em/ex/ag/co/op totals) ---
robustness <- lmer(hrate ~ guilt_scaled + pfc + crt_total + hh_total + em_total + ex_total + ag_total + co_total + op_total + (1 | username_new) + (1 | case), data = data_clean)
summary(robustness)

# --- Additional Visualizations ---
# Fig 1: Distribution of guilt
ggplot(data_clean, aes(x = guilt_scaled)) + geom_histogram() + labs(title = "Distribution of Guilt Ratings")

# Fig 2: Search by phase (mean signchosenevidence_rev by phase)
data_clean %>% group_by(phase) %>% summarise(mean_sign = mean(signchosenevidence_rev)) %>%
  ggplot(aes(x = phase, y = mean_sign)) + geom_bar(stat = "identity") + labs(title = "Information Search by Phase")

# Fig 3: hrate vs guilt by valence and condition
ggplot(data_clean, aes(x = guilt_scaled, y = hrate, color = bedingung)) +
  geom_jitter(alpha = 0.1) + geom_smooth(method = "lm") +
  facet_wrap(~ valence) + labs(title = "Coherence by Valence and Condition") +
  theme_minimal()
