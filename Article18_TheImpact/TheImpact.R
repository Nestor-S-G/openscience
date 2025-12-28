# Replication Script: "The impact of language on decision-making" (Fu et al., 2025)
# Final version: Aligned with PDF Page 6 (Round 1) and Section 3.3 (Dynamic Panel)

# Load required libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(haven, dplyr, tidyr, ggplot2, plm, lmtest, sandwich)

# 1. LOAD DATA
# Using winsorized data as per the main analysis in the paper
df <- read_dta("Beijing2017cleanedData_winsorized_merged.dta")

# 2. DATA PREPARATION
df <- df %>%
  mutate(
    Language = factor(Language, levels = c(0, 1), labels = c("Native", "Foreign")),
    round = as.integer(round),
    # Pre-calculated deviations in the dataset
    bid_dev_ne = Bid_Auc - Bid_NE_Auc,
    bid_dev_naive = Bid_Auc - Bid_N_Auc
  ) %>%
  arrange(ID, round)

# 3. ANALYSIS OF ROUND 1 (PDF Page 6 Results)
df_r1 <- df %>% filter(round == 1)

# Calculate group means for Naive deviation
r1_stats <- df_r1 %>%
  group_by(Language) %>%
  summarise(
    mean_naive_dev = mean(bid_dev_naive, na.rm = TRUE),
    sd_naive_dev = sd(bid_dev_naive, na.rm = TRUE),
    n = n()
  )

# T-test for the difference in Round 1
t_test_r1 <- t.test(bid_dev_naive ~ Language, data = df_r1)

# 4. PREPARE DYNAMIC PANEL (Section 3.3 Learning Model)
# Calculate Z_lag (Error update mechanism)
df <- df %>%
  group_by(S, round) %>%
  mutate(winner_bid = max(Bid_Auc, na.rm = TRUE)) %>%
  group_by(ID) %>%
  mutate(
    prev_winner_bid = lag(winner_bid),
    prev_ERNNE_v = lag(ERNNE_v),
    prev_ENaive_v = lag(ENaive_v),
    prev_Chi = lag(Chi_Auc),
    # Z_lag = surprise from previous winning bid vs expected cursed equilibrium
    exp_cursed_bid_prev = (1 - prev_Chi) * prev_ERNNE_v + prev_Chi * prev_ENaive_v,
    Z_lag = prev_winner_bid - exp_cursed_bid_prev
  ) %>%
  ungroup()

# Filter for Rounds 2-10 and create interactions
df_dynamic <- df %>%
  filter(round > 1) %>%
  mutate(
    Foreign = ifelse(Language == "Foreign", 1, 0),
    Foreign_Z = Foreign * Z_lag
  )

# 5. EXECUTE GMM MODEL (Arellano-Bond)
pdata <- pdata.frame(df_dynamic, index = c("ID", "round"))

model_gmm <- pgmm(Chi_Auc ~ lag(Chi_Auc, 1) + Z_lag + Foreign_Z | lag(Chi_Auc, 2:3),
                  data = pdata, 
                  effect = "individual", 
                  model = "onestep",
                  transformation = "ld")

# 6. OUTPUT COMPARISON TABLE DATA
cat("\n========================================================\n")
cat("   SECTION 3.1: ROUND 1 DESCRIPTIVES (PDF PAGE 6)\n")
cat("========================================================\n")
cat("Native Mean Naive Dev (Paper: -4.76):  ", round(r1_stats$mean_naive_dev[1], 2), "\n")
cat("Foreign Mean Naive Dev (Paper: -20.23): ", round(r1_stats$mean_naive_dev[2], 2), "\n")
cat("Difference (Paper: -15.47):             ", round(r1_stats$mean_naive_dev[2] - r1_stats$mean_naive_dev[1], 2), "\n")
cat("t-statistic (Paper: 4.37):              ", round(abs(t_test_r1$statistic), 2), "\n")
cat("p-value (Paper: < 0.001):               ", format.pval(t_test_r1$p.value), "\n")

cat("\n========================================================\n")
cat("   SECTION 3.3: DYNAMIC LEARNING MODEL\n")
cat("========================================================\n")
print(summary(model_gmm, robust = TRUE))

# 7. GENERATE FIGURE 3
fig3 <- ggplot(df, aes(x = round, y = bid_dev_ne, color = Language)) +
  stat_summary(fun = mean, geom = "line", linewidth = 1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  labs(title = "Replication of Figure 3: Bid Deviation from RNNE",
       subtitle = "Full Sample (N=357)",
       x = "Auction Round", y = "Average Deviation") +
  theme_minimal()

# Create folder and save
if (!dir.exists("figure")) dir.create("figure")
ggsave("figure/Replicated_Figure3_Full.png", plot = fig3, width = 8, height = 6)