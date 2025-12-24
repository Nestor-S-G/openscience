# REPRODUCTION SCRIPT: Fišar et al. (2023)
# Purpose: Replicate main results using all provided .dta files (behavioral and bio/hormonal data)
# Methodology: Linear models (lm) as data lacks repeated measures for mixed effects
# Fixes: Adjusted formula construction for dual-hormone models to ensure proper spacing and parsing (fixing the 'unexpected symbol' error)

library(haven)     # For reading .dta files
library(dplyr)     # Data manipulation
library(tidyr)     # Reshaping
library(tidyverse) # General tidyverse utilities

# 1. DATA LOADING - Load all 4 files and bind behavioral data
files <- c("GAMU_DATA_00.dta", "GAMU_DATA_01.dta", "GAMU_DATA_02.dta", "GAMU_DATA_03.dta")
raw_data <- lapply(files, read_dta) %>% bind_rows()

# 2. DATA NORMALIZATION
colnames(raw_data) <- tolower(colnames(raw_data))

# 3. ROBUST DATA AGGREGATION
# Aggregate repeated measures to session-level means
df_merged <- raw_data %>%
  group_by(uniid, session) %>%
  summarise(
    risk_bret = mean(bretchoice, na.rm = TRUE),  # BRET risk measure
    cheating_dice = mean(diceroll_a, na.rm = TRUE),  # Dice rule violation (adjust if named 'diceroll_diceroll1')
    exploration_tree = mean(tree_n, na.rm = TRUE),  # Exploration task (tree/foraging)
    female = first(na.omit(female)),
    uses_contraceptive = first(na.omit(menstr8)),  # 0 = natural cycling
    menstrtreat = first(na.omit(menstrtreat)),  # 0 = Menstruation, 1 = Ovulation
    crt_score = first(na.omit(crt_score)),
    estradiol = mean(estradiol, na.rm = TRUE),
    testosterone = mean(testosterone, na.rm = TRUE),
    cortisol = mean(cortisol, na.rm = TRUE),
    haircortisol = first(na.omit(haircortisol_1)),
    y1score = first(na.omit(y1score)),  # State anxiety
    y2score = first(na.omit(y2score)),  # Trait anxiety
    .groups = "drop"
  ) %>%
  filter(female == 0 | (female == 1 & uses_contraceptive == 0)) %>%  # Males + natural-cycling females
  mutate(
    menstrtreat = as.factor(menstrtreat),  # 0 = Menstruation, 1 = Ovulation
    ovulation = ifelse(menstrtreat == 1, 1, 0),  # Dummy for models
    session2 = ifelse(session == 2, 1, 0),  # Create session order dummy
    log_estradiol = log(estradiol),
    log_testosterone = log(testosterone),
    log_cortisol = log(cortisol)
  )

# Subsets for female-only models
df_females <- df_merged %>% filter(female == 1)
df_males <- df_merged %>% filter(female == 0)

# Controls
controls <- c("session2", "crt_score")

# 4. STATISTICAL ANALYSIS: RISK PREFERENCES (BRET) - Table 2
cat("\n--- REPLICATION: RISK TAKING (BRET) - Table 2 ---\n")
# Model (1): Pooled (females + males) - use lm since no repeats
formula_pooled <- as.formula(paste("risk_bret ~ female + female * ovulation +", paste(controls, collapse = " + ")))
model_risk_pooled <- lm(formula_pooled, data = df_merged)
print(summary(model_risk_pooled))

# Model (2): Females only
formula_females <- as.formula(paste("risk_bret ~ ovulation +", paste(controls, collapse = " + ")))
model_risk_females <- lm(formula_females, data = df_females)
print(summary(model_risk_females))

# Model (3): Females with hormones (levels)
formula_hormones <- as.formula(paste("risk_bret ~ estradiol + testosterone + cortisol + haircortisol +", paste(controls, collapse = " + ")))
model_risk_hormones <- lm(formula_hormones, data = df_females)
print(summary(model_risk_hormones))

# Model (4): Females with y1score (state anxiety)
formula_y1 <- as.formula(paste("risk_bret ~ estradiol + testosterone + y1score +", paste(controls, collapse = " + ")))
model_risk_y1 <- lm(formula_y1, data = df_females)
print(summary(model_risk_y1))

# Model (5): Females with y2score (trait anxiety)
formula_y2 <- as.formula(paste("risk_bret ~ estradiol + testosterone + y2score +", paste(controls, collapse = " + ")))
model_risk_y2 <- lm(formula_y2, data = df_females)
print(summary(model_risk_y2))

# Models (6-8): Males (repeat hormones, y1, y2)
model_risk_males_hormones <- lm(formula_hormones, data = df_males)
print(summary(model_risk_males_hormones))
# Repeat for y1 and y2 on males if needed

# 5. STATISTICAL ANALYSIS: RULE VIOLATION (DICE TASK) - Table 3
cat("\n--- REPLICATION: RULE VIOLATION (DICE) - Table 3 ---\n")
# Similar to risk, replace outcome
formula_pooled_cheat <- as.formula(gsub("risk_bret", "cheating_dice", deparse(formula_pooled)))
model_cheat_pooled <- lm(formula_pooled_cheat, data = df_merged)
print(summary(model_cheat_pooled))

formula_females_cheat <- as.formula(gsub("risk_bret", "cheating_dice", deparse(formula_females)))
model_cheat_females <- lm(formula_females_cheat, data = df_females)
print(summary(model_cheat_females))

formula_hormones_cheat <- as.formula(gsub("risk_bret", "cheating_dice", deparse(formula_hormones)))
model_cheat_hormones <- lm(formula_hormones_cheat, data = df_females)
print(summary(model_cheat_hormones))
# Add y1/y2 models similarly

# 6. STATISTICAL ANALYSIS: EXPLORATORY ATTITUDE (TREE/FORAGING) - Table 4
cat("\n--- REPLICATION: EXPLORATION (TREE) - Table 4 ---\n")
# Similar structure
formula_pooled_explor <- as.formula(gsub("risk_bret", "exploration_tree", deparse(formula_pooled)))
model_explor_pooled <- lm(formula_pooled_explor, data = df_merged)
print(summary(model_explor_pooled))

formula_females_explor <- as.formula(gsub("risk_bret", "exploration_tree", deparse(formula_females)))
model_explor_females <- lm(formula_females_explor, data = df_females)
print(summary(model_explor_females))

formula_hormones_explor <- as.formula(gsub("risk_bret", "exploration_tree", deparse(formula_hormones)))
model_explor_hormones <- lm(formula_hormones_explor, data = df_females)
print(summary(model_explor_hormones))
# Add y1/y2 models

# 7. DUAL-HORMONE HYPOTHESIS - Table 5 (Levels, Pooled)
cat("\n--- REPLICATION: DUAL-HORMONE (LEVELS) - Table 5 ---\n")
formula_dual_terms <- paste("testosterone + cortisol + testosterone:cortisol + female +", paste(controls, collapse = " + "))
formula_dual_risk <- as.formula(paste("risk_bret ~", formula_dual_terms))
model_dual_risk <- lm(formula_dual_risk, data = df_merged)
print(summary(model_dual_risk))

formula_dual_cheat <- as.formula(paste("cheating_dice ~", formula_dual_terms))
model_dual_cheat <- lm(formula_dual_cheat, data = df_merged)
print(summary(model_dual_cheat))

formula_dual_explor <- as.formula(paste("exploration_tree ~", formula_dual_terms))
model_dual_explor <- lm(formula_dual_explor, data = df_merged)
print(summary(model_dual_explor))

# 8. DUAL-HORMONE HYPOTHESIS - Table 6 (Logs, Pooled)
cat("\n--- REPLICATION: DUAL-HORMONE (LOGS) - Table 6 ---\n")
formula_dual_log_terms <- gsub("testosterone", "log_testosterone", gsub("cortisol", "log_cortisol", formula_dual_terms))
formula_dual_risk_log <- as.formula(paste("risk_bret ~", formula_dual_log_terms))
model_dual_risk_log <- lm(formula_dual_risk_log, data = df_merged)
print(summary(model_dual_risk_log))

formula_dual_cheat_log <- as.formula(paste("cheating_dice ~", formula_dual_log_terms))
model_dual_cheat_log <- lm(formula_dual_cheat_log, data = df_merged)
print(summary(model_dual_cheat_log))

formula_dual_explor_log <- as.formula(paste("exploration_tree ~", formula_dual_log_terms))
model_dual_explor_log <- lm(formula_dual_explor_log, data = df_merged)
print(summary(model_dual_explor_log))

# 9. SUMMARY TABLE: AGGREGATED OUTCOMES BY CYCLE PHASE (Females Only)
cat("\n--- DESCRIPTIVE SUMMARY BY CYCLE PHASE (FEMALES) ---\n")
summary_table <- df_females %>%
  group_by(menstrtreat) %>%
  summarise(
    n = n(),
    risk_mean = mean(risk_bret, na.rm = TRUE),
    cheating_mean = mean(cheating_dice, na.rm = TRUE),
    exploration_mean = mean(exploration_tree, na.rm = TRUE)
  )
print(summary_table)
