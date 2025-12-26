# ==============================================================================
# FULL REPRODUCTION SCRIPT: Zhang et al. (2024)
# Translating all Stata (.do) logic to R - FIXED VERSION
# ==============================================================================

# 1. LOAD LIBRARIES
if(!require(haven)) install.packages("haven")
if(!require(tidyverse)) install.packages("tidyverse")
if(!require(lmerTest)) install.packages("lmerTest")
if(!require(coin)) install.packages("coin") 

library(haven)
library(tidyverse)
library(lmerTest)

# 2. DATA LOADING & GLOBAL PREPROCESSING
data_raw <- read_dta("workdata.dta")

df_clean <- data_raw %>%
  filter(check != 1) %>%
  mutate(
    # Format & Presentation (0,1 = Vertical; 2,3 = Horizontal)
    hori = ifelse(presentation %in% c(2, 3), 1, 0),
    hardhori = hard * hori,
    
    # Choice variables cleanup (match Stata's replace if choice==.)
    highepchoice = ifelse(is.na(choice), NA, highepchoice),
    riskychoice = ifelse(is.na(choice), NA, riskychoice),
    
    # EMV Calculations
    hemvh = pmax(ep1, ep2),
    lemvh = pmin(ep1, ep2),
    diff_emv = hemvh - lemvh,
    hmvrisk = ifelse(ep2 > ep1, 1, 0),
    diff_risk = ep2 - ep1,
    
    # Eye-tracking Transition Ratios (Logic from table_1b.do and table_2b.do)
    total_t = t12 + t13 + t14 + t23 + t24 + t34,
    peu = case_when(
      presentation %in% c(0, 1) ~ (t13 + t24) / total_t,
      presentation %in% c(2, 3) ~ (t12 + t34) / total_t
    ),
    pcc = case_when(
      presentation %in% c(0, 1) ~ (t12 + t34) / total_t,
      presentation %in% c(2, 3) ~ (t13 + t24) / total_t
    ),
    
    # Fixation Durations (Logic from table_4a.do)
    total_f = fixonpay1 + fixonpay2 + fixonpr1 + fixonpr2,
    ppay1 = fixonpay1 / total_f,
    ppay2 = fixonpay2 / total_f,
    phep = ifelse(ep1 > ep2, ppay1, ppay2),
    payne = (eut - cct) / (eut + cct)
  )

# ==============================================================================
# 3. REPRODUCING TABLES 1-4 (Subject-level Wilcoxon Tests)
# ==============================================================================
cat("\n--- Tables 1-4: Wilcoxon Signed-Rank Tests (Comparing Easy vs Hard) ---\n")

# Aggregate by Subject and Difficulty (Hard) to mimic Stata's 'collapse'
subject_hard <- df_clean %>%
  group_by(subject, hard) %>%
  summarise(peu = mean(peu, na.rm = TRUE), .groups = 'drop') %>%
  pivot_wider(names_from = hard, values_from = peu, names_prefix = "hard_")

# Wilcoxon Test for EU transitions (Table 1b logic)
wilcox_result <- wilcox.test(subject_hard$hard_0, subject_hard$hard_1, paired = TRUE)
print(paste("Wilcoxon p-value for EU transitions (Easy vs Hard):", round(wilcox_result$p.value, 4)))

# ==============================================================================
# 4. REPRODUCING TABLES 5, 7, & 8 (Mixed Models)
# ==============================================================================

# Table 5: High EMV Choice
cat("\n--- Table 5: Determinants of High EMV Choice (Model 4) ---\n")
t5_m4 <- lmer(highepchoice ~ hard + hori + hardhori + diff_emv + hmvrisk + round + (1|subject), data = df_clean)
print(summary(t5_m4)$coefficients)

# Table 7: Risky Choice
cat("\n--- Table 7: Determinants of Risky Choice (Model 4) ---\n")
t7_m4 <- lmer(riskychoice ~ hard + hori + hardhori + diff_risk + hmvrisk + round + (1|subject), data = df_clean)
print(summary(t7_m4)$coefficients)

# Table 8: Eye-tracking and Decisions
cat("\n--- Table 8: Cognitive Process Predictors ---\n")
t8_panelA <- lmer(highepchoice ~ payne + phep + reactiontime + (1|subject), data = df_clean)
print(summary(t8_panelA)$coefficients)

# ==============================================================================
# 5. REPRODUCING FIGURE 3 (RT Density Plot)
# ==============================================================================
df_fig3 <- df_clean %>%
  arrange(reactiontime) %>%
  slice(1:4750) # Drop longest 5% (Total trials = 5000)

ggplot(df_fig3, aes(x = reactiontime, color = as.factor(hori), linetype = as.factor(hard))) +
  geom_density(linewidth = 1) +
  scale_color_manual(values = c("0" = "orange", "1" = "navy"), 
                     labels = c("Vertical", "Horizontal")) +
  scale_linetype_manual(values = c("0" = "solid", "1" = "dotdash"), 
                        labels = c("Easy", "Hard")) +
  labs(title = "Figure 3: Reaction Time Densities",
       x = "Reaction Time", y = "Density", color = "Format", linetype = "Difficulty") +
  theme_minimal()
