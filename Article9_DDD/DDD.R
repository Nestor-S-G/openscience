if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, tidyverse, janitor, sandwich, lmtest, car)
library(readxl)
library(tidyverse)
library(janitor)

# 1. LOAD THE DATA
# Replace "Data DDD.xlsx" with the actual path to your file
file_path <- "/home/nestor/Documentos/Zürich/TFM/Domain-Dependent/Data DDD.xlsx"
df_raw <- read_excel(file_path)

# 2. LOAD AND CLEAN DATA
# Use read_excel. We will manually remove the Qualtrics metadata rows.
raw_df <- read_excel("Data DDD.xlsx")

df <- raw_df %>%
  # Remove the first two rows (Qualtrics labels/metadata)
  slice(-c(1, 2)) %>%
  # Clean column names to be R-friendly (lowercase, underscores)
  clean_names() %>%
  # Filter out any non-consented or non-treatment rows
  filter(consent == "1", treatment %in% c("STOCK", "BENCHMARK")) %>%
  # Convert numeric columns from character to numeric
  mutate(across(c(
    contains("decision"), 
    contains("financial_literacy"), 
    age, 
    willingness_to_take_risks,
    contains("experience")
  ), as.numeric))

# 3. CONSTRUCT CONTROL VARIABLES
# Financial Literacy: Sum of 9 questions
df <- df %>%
  mutate(fin_lit_score = rowSums(select(., contains("financial_literacy_question")), na.rm = TRUE))

# Identify the correct experience column
# Qualtrics often appends _2 or _1 to the demographic experience question at the end
# We use 'investment_experience_2' or whatever clean_names() produced for the second instance.
# Let's rename them for safety:
df <- df %>%
  rename(
    exp_years = contains("experience") %>% last(), # Usually the demographic one at the end
    risk_appetite = willingness_to_take_risks,
    gender_female = female
  )

# 4. REPRODUCE TABLE 2 (Mean Correlation Choices)
table_2 <- df %>%
  group_by(treatment) %>%
  summarise(
    N = n(),
    Mean_Gain  = mean(if_else(treatment == "STOCK", stock_gain_decision, benchmark_gain_decision), na.rm = TRUE),
    Mean_Mixed = mean(if_else(treatment == "STOCK", stock_mixed_decision, benchmark_mixed_decision), na.rm = TRUE),
    Mean_Loss  = mean(if_else(treatment == "STOCK", stock_loss_decision, benchmark_loss_decision), na.rm = TRUE)
  )

print("--- REPRODUCED TABLE 2: MEAN RHO BY DOMAIN ---")
print(table_2)

# 5. REPRODUCE HYPOTHESIS 1 (STOCK Group: Loss vs Gain)
stock_only <- df %>% filter(treatment == "STOCK")
h1_test <- t.test(stock_only$stock_loss_decision, 
                  stock_only$stock_gain_decision, 
                  paired = TRUE)

print("--- HYPOTHESIS 1 TEST (STOCK LOSS VS GAIN) ---")
print(h1_test)

# 6. REPRODUCE TABLE 3 (Regression Analysis with Controls)
# We pivot to long format so each participant has 3 rows (Gain, Mixed, Loss)
df_long <- stock_only %>%
  select(response_id, stock_gain_decision, stock_mixed_decision, stock_loss_decision,
         fin_lit_score, exp_years, risk_appetite, gender_female, age) %>%
  pivot_longer(cols = starts_with("stock_"), 
               names_to = "domain", 
               values_to = "rho_choice") %>%
  mutate(domain = factor(domain, 
                         levels = c("stock_gain_decision", "stock_mixed_decision", "stock_loss_decision"),
                         labels = c("Gain", "Mixed", "Loss")))

# Regression: The paper uses Gain as the baseline
model_table3 <- lm(rho_choice ~ domain + fin_lit_score + exp_years + risk_appetite + gender_female + age, 
                   data = df_long)

print("--- REPRODUCED TABLE 3: REGRESSION ANALYSIS ---")
summary(model_table3)