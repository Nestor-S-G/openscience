# ==============================================================================
# COMPUTATIONAL REPRODUCTION: Zhang et al. (2024)
# Stata to R Translation for Open Science Reproducibility
# ==============================================================================

# 1. LOAD LIBRARIES
if(!require(haven)) install.packages("haven")     # To read .dta files
if(!require(tidyverse)) install.packages("tidyverse") # Data manipulation & plotting
if(!require(lmerTest)) install.packages("lmerTest")   # Mixed-effects models with p-values

library(haven)
library(tidyverse)
library(lmerTest)

# 2. DATA LOADING AND PREPROCESSING (Consolidating all .do logic)
# Ensure "workdata.dta" is in your working directory
data_raw <- read_dta("workdata.dta")

df <- data_raw %>%
  # Filter check trials as seen in all scripts
  filter(check != 1) %>% 
  mutate(
    # Clean missing choices (Table 5, 7, 8 logic)
    highepchoice = ifelse(is.na(choice), NA, highepchoice),
    riskychoice = ifelse(is.na(choice), NA, riskychoice),
    
    # Format and Difficulty Variables
    hori = ifelse(presentation %in% c(2, 3), 1, 0),
    hardhori = hard * hori,
    
    # Expected Monetary Value (EMV) Variables
    hemvh = pmax(ep1, ep2),
    lemvh = pmin(ep1, ep2),
    diff = hemvh - lemvh,
    hmvrisk = ifelse(ep2 > ep1, 1, 0),    # Is High EMV the Risky choice?
    diff_risk = ep2 - ep1,                # Risky EMV - Safe EMV
    
    # Eye-tracking Metrics (Transitions & Fixations)
    total_trans = t12 + t13 + t14 + t23 + t24 + t34,
    total_fix_dur = fixonpay1 + fixonpay2 + fixonpr1 + fixonpr2,
    
    # Classification of Eye Movements (Table 1b, 2b, 3)
    # EU (Expected Utility) vs CC (Component Comparison) depends on screen layout
    peu = case_when(
      presentation %in% c(0, 1) ~ (t13 + t24) / total_trans,
      presentation %in% c(2, 3) ~ (t12 + t34) / total_trans
    ),
    pcc = case_when(
      presentation %in% c(0, 1) ~ (t12 + t34) / total_trans,
      presentation %in% c(2, 3) ~ (t13 + t24) / total_trans
    ),
    
    # Indices for Table 8
    payne = (eut - cct) / (eut + cct),
    ppay1 = fixonpay1 / total_fix_dur,
    ppay2 = fixonpay2 / total_fix_dur,
    phep = ifelse(ep1 > ep2, ppay1, ppay2) # Fixation on higher EMV option
  )

# ==============================================================================
# 3. STATISTICAL ANALYSIS (REPRODUCING CORE TABLES)
# ==============================================================================

# --- TABLE 5: Determinants of choosing high EMV option ---
cat("\n--- Reproducing Table 5 (Model 4) ---\n")
# Stata: mixed highepchoice hard hori hardhori diff hmvrisk round || subject: ...
# In R, we use random intercepts for stability; (1|subject)
t5_mod4 <- lmer(highepchoice ~ hard + hori + hardhori + diff + hmvrisk + round + 
                  (1 | subject), data = df)
print(summary(t5_mod4))

# --- TABLE 7: Determinants of Risky Choice ---
cat("\n--- Reproducing Table 7 (Model 4) ---\n")
t7_mod4 <- lmer(riskychoice ~ hard + hori + hardhori + diff_risk + hmvrisk + round + 
                  (1 | subject), data = df)
print(summary(t7_mod4))

# --- TABLE 8: Cognitive Processes and Decision ---
cat("\n--- Reproducing Table 8 (Panel A & B) ---\n")
# Panel A: EMV Choice explained by Eye-tracking
t8a <- lmer(highepchoice ~ payne + phep + reactiontime + (1 | subject), data = df)
# Panel B: Risky Choice explained by Eye-tracking
t8b <- lmer(riskychoice ~ payne + ppay2 + reactiontime + (1 | subject), data = df)
print(summary(t8a))
print(summary(t8b))

# ==============================================================================
# 4. VISUALIZATION (REPRODUCING FIGURE 3)
# ==============================================================================

# Filtering as per figure_3.do (dropping the longest 5% / keeping 4750 trials)
df_fig3 <- df %>%
  arrange(reactiontime) %>%
  slice(1:4750) %>%
  mutate(Condition = case_when(
    hori == 0 & hard == 0 ~ "Vertical-Easy",
    hori == 0 & hard == 1 ~ "Vertical-Hard",
    hori == 1 & hard == 0 ~ "Horizontal-Easy",
    hori == 1 & hard == 1 ~ "Horizontal-Hard"
  ))

ggplot(df_fig3, aes(x = reactiontime, color = Condition, linetype = Condition)) +
  geom_density(linewidth = 1) +
  scale_color_manual(values = c("Vertical-Easy" = "orange", "Vertical-Hard" = "orange", 
                                "Horizontal-Easy" = "navy", "Horizontal-Hard" = "navy")) +
  scale_linetype_manual(values = c("Vertical-Easy" = "solid", "Vertical-Hard" = "dotdash", 
                                   "Horizontal-Easy" = "solid", "Horizontal-Hard" = "dotdash")) +
  labs(title = "Figure 3: Reaction Time Densities",
       x = "Reaction Time", y = "Smoothed Kernel Density") +
  theme_minimal() +
  theme(legend.position = "bottom")

# ==============================================================================
# END OF SCRIPT
# ==============================================================================