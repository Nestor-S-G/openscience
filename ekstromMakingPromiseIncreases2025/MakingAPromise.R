# Load libraries
library(RRreg)
library(tidyverse)
library(fixest)

# 1. Load the data 
# Ensure the file is in your working directory
df <- read.csv("ekstromMakingPromiseIncreases2025/data_combined.csv")

# --- REPRODUCING MAIN RESULTS (TABLE 2 / REGRESSIONS) ---

# Experiment 1: Effect of Promise & Trust (T1) vs Control (T0)
# Variables: correct_guess (DV), trust_promise (IV)
model_exp1 <- feols(correct_guess ~ trust_promise, 
                    data = filter(df, experiment == 1), 
                    vcov = "HC1")
summary(model_exp1)

# Experiment 2: Effect of Promise (T2), Trust (T3), and Promise & Trust (T1)
# Note: Control group is the reference (intercept)
model_exp2 <- feols(correct_guess ~ promise + trust + trust_promise, 
                    data = filter(df, experiment == 2), 
                    vcov = "HC1")
summary(model_exp2)

# Experiment 3: Main treatment effects (Table 1, U.S. sample)
# Note: Control group is the reference (intercept)
model_exp3_main <- feols(
  correct_guess ~ promise + trust + trust_promise,
  data = filter(df, experiment == 3),
  vcov = "HC1"
)
summary(model_exp3_main)

# Experiment 3: Default effects (Table A.4 logic)
# Here Default_yes and Default_no enter as additional treatments vs Control
model_exp3_defaults <- feols(
  correct_guess ~ promise + trust + trust_promise + default_yes + default_no,
  data = filter(df, experiment == 3),
  vcov = "HC1"
)
summary(model_exp3_defaults)

# --- REPRODUCING PROPORTION OF DISHONESTY (Moshagen & Hilbig Method) ---

# Helper function using the variables from your CSV
calculate_dishonesty <- function(d, exp_id, treatment_name) {
  # Filter data
  sub_data <- d %>% filter(experiment == exp_id, treatment == treatment_name)
  
  # Reported wins (correct_guess == 1)
  r <- sub_data$correct_guess
  
  # Probability of winning by chance (1/6)
  p_chance <- 1/6
  
  # Run RR model
  res <- RRuni(r, model = "FR", p = c(0, p_chance))
  cat("\n--- Results for", treatment_name, "(Exp", exp_id, ") ---\n")
  print(summary(res))
}

# Example: Reproduce Exp 1 Control results
calculate_dishonesty(df, 1, "Control")

# Example: Reproduce Exp 1 Promise & Trust results
calculate_dishonesty(df, 1, "Trust_promise")
