# Reproduction Script for Aydogan, Berger, and Theroude (2024)
# Replicating all results from "Pay all subjects or pay only some?"

# 1. Load Required Libraries
library(haven)     # For reading Stata (.dta) files [cite: 1]
library(tidyverse) # For data manipulation
library(estimatr)  # For OLS with robust standard errors (Table 2)
library(coin)      # For exact Mann-Whitney U tests (Table 1)

# 2. Import Dataset
# Assuming "db.dta" is the final data used for analysis [cite: 1]
df <- read_dta("db.dta")

# 3. Data Preparation and Variable Calculation
# We must calculate the premiums as defined in the documentation 
df <- df %>%
  mutate(
    # treatment_between: 1 if "10%", 0 if "100%" 
    treatment = factor(treatment_between, levels = c(0, 1), labels = c("PPS", "RPS")),
    
    # Risk Premium: CE of Risk minus expected value (10) 
    # Note: Using CE_R100 for the 100-ball urn 
    RiskPremium_R = CE_R100 - 10,
    
    # Ambiguity Premium: CE of Risk - CE of Ambiguity 
    AmbiguityPremium_ = CE_R100 - CE_MA_U_100,
    
    # Compound Risk (CR) Premium: CE of Risk - CE of CR 
    CRPremium_ = CE_R100 - CE_CR_U_100,
    
    # Demographics [cite: 5]
    female = as.numeric(Female1Male0)
  ) %>%
  # Filter out missing observations (no precise indifference interval) 
  filter(!is.na(RiskPremium_R))

# --- SECTION 4: MAIN EXPERIMENTAL RESULTS ---

# 4.1 Treatment Effects (Table 1: Comparing PPS vs RPS) [cite: 1]
# These tests compare the 10% vs 100% payment schemes
mw_risk <- wilcox_test(RiskPremium_R ~ treatment, data = df, distribution = "exact")
mw_amb  <- wilcox_test(AmbiguityPremium_ ~ treatment, data = df, distribution = "exact")
mw_cr   <- wilcox_test(CRPremium_ ~ treatment, data = df, distribution = "exact")

# Print Mann-Whitney U test results for Table 1
print(mw_risk)
print(mw_amb)
print(mw_cr)

# 4.2 Within-Subject Comparisons (Section 5.1.2)
# Comparing Ambiguity vs Compound Risk attitudes
wilcox_amb_vs_cr <- wilcox.test(df$AmbiguityPremium_, df$CRPremium_, paired = TRUE)
print(wilcox_amb_vs_cr)

# --- SECTION 5: REGRESSION ANALYSIS (Table 2) ---

# 5.1 OLS Regressions with Robust Standard Errors [cite: 1]
# Replicating the impact of treatment and demographics on premiums [cite: 5]

# Regression for Risk Premium
model_risk <- lm_robust(RiskPremium_R ~ treatment + Age + female + Education, 
                        data = df, se_type = "HC1")

# Regression for Ambiguity Premium
model_amb <- lm_robust(AmbiguityPremium_ ~ treatment + Age + female + Education, 
                       data = df, se_type = "HC1")

# Regression for Compound Risk Premium
model_cr <- lm_robust(CRPremium_ ~ treatment + Age + female + Education, 
                      data = df, se_type = "HC1")

# Summarize Table 2 results
summary(model_risk)
summary(model_amb)
summary(model_cr)

# Categorizing Attitudes for Table 6
# An individual is Neutral if the Premium is 0, Averse if > 0, and Seeking if < 0.
df <- df %>%
  mutate(
    Attitude_Amb_U = case_when(
      AmbiguityPremium_ > 0 ~ "Aversion",
      AmbiguityPremium_ == 0 ~ "Neutrality",
      AmbiguityPremium_ < 0 ~ "Seeking"
    ),
    # Repeat for CR and other configurations...
  )

# Association Table for Table 7
# Ambiguity Neutrality vs. Compound Risk Reduction
table_7 <- table(df$Attitude_Amb_U == "Neutrality", df$CRPremium_ == 0)
fisher.test(table_7)

# --- FINAL REPRODUCTION STEPS ---

# 1. Distribution of Attitudes (Table 6)
# Calculating percentages for Ambiguity and Compound Risk attitudes
table_6_dist <- df %>%
  group_by(treatment) %>%
  summarise(
    Amb_Aversion = mean(AmbiguityPremium_ > 0, na.rm = TRUE) * 100,
    Amb_Neutral  = mean(AmbiguityPremium_ == 0, na.rm = TRUE) * 100,
    Amb_Seeking  = mean(AmbiguityPremium_ < 0, na.rm = TRUE) * 100,
    CR_Aversion  = mean(CRPremium_ > 0, na.rm = TRUE) * 100,
    CR_Neutral   = mean(CRPremium_ == 0, na.rm = TRUE) * 100,
    CR_Seeking   = mean(CRPremium_ < 0, na.rm = TRUE) * 100
  )
print(table_6_dist)

# 2. Directional Analysis (Section 5.1.2)
# Comparing U vs D configurations to check for 'source' effects
# Ambiguity U vs D
df$Amb_D_Premium <- df$CE_R100 - df$CE_MA_D_100
wilcox_amb_u_v_d <- wilcox.test(df$AmbiguityPremium_, df$Amb_D_Premium, paired = TRUE)

# Compound Risk U vs D
df$CR_D_Premium <- df$CE_R100 - df$CE_CR_D_100
wilcox_cr_u_v_d <- wilcox.test(df$CRPremium_, df$CR_D_Premium, paired = TRUE)

print(wilcox_amb_u_v_d)
print(wilcox_cr_u_v_d)

# 3. Online Appendix Reproduction (Urns with 2 balls)
# Repeating Table 1 tests for the small urn scenario
df_2ball <- df %>%
  mutate(
    RiskPremium_2  = CE_R2 - 10,
    AmbPremium_2   = CE_R2 - CE_MA_U_2,
    CRPremium_2    = CE_R2 - CE_CR_U_2
  )

mw_risk_2 <- wilcox_test(RiskPremium_2 ~ treatment, data = df_2ball, distribution = "exact")
mw_amb_2  <- wilcox_test(AmbPremium_2 ~ treatment, data = df_2ball, distribution = "exact")
mw_cr_2   <- wilcox_test(CRPremium_2 ~ treatment, data = df_2ball, distribution = "exact")

print(mw_risk_2)
print(mw_amb_2)
print(mw_cr_2)

# 4. Summary Statistics for Demographics (Table in Section 3)
# To verify the balance between PPS and RPS groups
demo_summary <- df %>%
  group_by(treatment) %>%
  summarise(
    Mean_Age = mean(Age, na.rm = TRUE),
    Prop_Female = mean(female, na.rm = TRUE),
    N = n()
  )
print(demo_summary)