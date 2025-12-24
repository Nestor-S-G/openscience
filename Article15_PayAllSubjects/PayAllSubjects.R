# Reproduction Script for Aydogan, Berger, and Theroude (2024)
# Goal: Match exact numerical outputs from Tables 3, 5, and 6

# 1. Load Required Libraries
library(haven)     # For reading Stata (.dta) files
library(tidyverse) # For data manipulation
library(estimatr)  # For OLS with robust standard errors (Table 2)

# 2. Import Dataset
df <- read_dta("db.dta")

# 3. Data Preparation
# Note: We use the actual variable names found in db.dta (e.g., Female1Male0)
df <- df %>%
  mutate(
    # treatment_between: 1 if "10%" (RPS), 0 if "100%" (PPS)
    treatment = factor(treatment_between, levels = c(0, 1), labels = c("PPS", "RPS")),
    
    # Premiums Calculation (Risk, Ambiguity U, and Compound Risk U)
    RiskPremium_R = CE_R100 - 10,
    AmbiguityPremium_ = CE_R100 - CE_MA_U_100,
    CRPremium_ = CE_R100 - CE_CR_U_100
  ) %>%
  # Filter missing observations (subjects without precise indifference interval)
  # This step is crucial to match the N and percentages in the paper
  filter(!is.na(RiskPremium_R))

# --- SECTION 4: TABLES 3 & 5 (T-TESTS FOR TREATMENT EFFECTS) ---

# Table 3: Risk (R) - CE comparison (Paper reports p=0.43)
t_test_risk <- t.test(CE_R100 ~ treatment, data = df, var.equal = FALSE)

# Table 5: Ambiguity (A-U) - CE comparison (Paper reports p=0.51)
t_test_amb <- t.test(CE_MA_U_100 ~ treatment, data = df, var.equal = FALSE)

# Table 5: Compound Risk (CR-U) - CE comparison
t_test_cr <- t.test(CE_CR_U_100 ~ treatment, data = df, var.equal = FALSE)

print("--- T-TEST RESULTS (MATCHING TABLES 3 & 5) ---")
print(t_test_risk)
print(t_test_amb)
print(t_test_cr)

# --- SECTION 5: TABLE 6 (DISTRIBUTION OF ATTITUDES) ---

# This matches the exact percentages in Table 6 (p. 7)
table_6_dist <- df %>%
  group_by(treatment) %>%
  summarise(
    Amb_Aversion = mean(AmbiguityPremium_ > 0, na.rm = TRUE) * 100,
    Amb_Neutral  = mean(AmbiguityPremium_ == 0, na.rm = TRUE) * 100,
    Amb_Seeking  = mean(AmbiguityPremium_ < 0, na.rm = TRUE) * 100,
    CR_Aversion  = mean(CRPremium_ > 0, na.rm = TRUE) * 100,
    CR_Neutral   = mean(CRPremium_ == 0, na.rm = TRUE) * 100,
    CR_Seeking   = mean(CRPremium_ < 0, na.rm = TRUE) * 100,
    N = n()
  )

print("--- ATTITUDE DISTRIBUTION (MATCHING TABLE 6) ---")
print(table_6_dist)

# --- SECTION 6: TABLE 2 (OLS REGRESSIONS WITH ROBUST SE) ---

# Replicating Table 2 using exact variable names from db.dta
# We use Female1Male0 instead of 'female'
model_risk <- lm_robust(RiskPremium_R ~ treatment + Age + Female1Male0 + Education, 
                        data = df, se_type = "HC1")

print("--- REGRESSION FOR RISK PREMIUM (MATCHING TABLE 2) ---")
summary(model_risk)
