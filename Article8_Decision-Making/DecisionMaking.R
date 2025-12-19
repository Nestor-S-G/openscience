library(readstata13)
library(AER)
library(marginaleffects)
library(car)

# 2. DATA LOADING & PREPARATION
df <- read.dta13("ahkjeboallvars.dta", nonint.factors = TRUE)

# Individual Treatments (T5 as reference)
df$treatment <- as.factor(df$treat5group)
df$treatment <- relevel(df$treatment, ref = "5")

# Pooled Treatments (Wife T1+T3 vs Husband T2+T4)
df$wife_pooled <- ifelse(df$treat5group %in% c(1, 3), 1, 0)
df$husband_pooled <- ifelse(df$treat5group %in% c(2, 4), 1, 0)

# 3. ANALYSIS: TABLE 2 (Descriptive Statistics - Mean WTP)
cat("\n--- TABLE 2: MEAN WTP BY GROUP (Nominal ETB) ---\n")
print(aggregate(WTP ~ treat5group, data = df, FUN = mean))

# 4. ANALYSIS: TABLE 3 (Individual and Pooled Models)

# Model A: Individual Treatments (Full Specification)
tobit_ind <- tobit(lWTP ~ treatment + age + educationlevel + hhsizze + 
                     valuetotalassets1000 + separtekitchen + 
                     hhwoodtime_monthly + factor(village), 
                   left = log(1), right = log(150), data = df)

ols_ind <- lm(lWTP ~ treatment + age + educationlevel + hhsizze + 
                valuetotalassets1000 + separtekitchen + 
                hhwoodtime_monthly + factor(village), data = df)

# Model B: Pooled Treatments (Wife vs Husband vs Joint)
tobit_pooled <- tobit(lWTP ~ wife_pooled + husband_pooled + age + educationlevel + 
                        hhsizze + valuetotalassets1000 + separtekitchen + 
                        hhwoodtime_monthly + factor(village), 
                      left = log(1), right = log(150), data = df)

# 5. MARGINAL EFFECTS (Reporting as per Table 3 Notes)
cat("\n--- MARGINAL EFFECTS (POOLED TOBIT - Target 0.339) ---\n")
print(avg_slopes(tobit_pooled, variables = c("wife_pooled", "husband_pooled")))

# 6. HYPOTHESIS TESTING (Wald Tests from Article Text)
cat("\n--- WALD TESTS (Comparing Coefficients) ---\n")
cat("Is T1 equal to T3? (Source of money effect)\n")
print(linearHypothesis(tobit_ind, "treatment1 = treatment3"))

# 7. FINAL DETAILED SUMMARIES
cat("\n--- TABLE 3: TOBIT (INDIVIDUAL TREATMENTS) ---\n")
print(summary(tobit_ind))

cat("\n--- TABLE 3: OLS (INDIVIDUAL TREATMENTS) ---\n")
print(summary(ols_ind))

# Total Observations
cat(paste("\nTotal N:", nrow(df), "\n"))
