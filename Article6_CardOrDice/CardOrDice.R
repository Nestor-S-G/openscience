## ---- Setup ----
library(readxl)
library(dplyr)
library(ggplot2)
library(MASS)

# Read data
dat <- readxl::read_excel("allresultsIV.xlsx")

# Inspect structure (optional)
str(dat)
names(dat)

## ---- Basic variable construction ----
dat <- dat %>%
  mutate(
    # Sample / place factor
    place_fac = factor(
      `place (3=Cambodia_classroom;; 1=Cambodia_farmers; 2= Germany_classroom, 4=Germany_laboratory)`,
      levels = c(1, 3, 2, 4),
      labels = c("Camb_farmers",
                 "Camb_students",
                 "Ger_class",
                 "Ger_lab")
    ),
    # Recoding 6 -> 0 for ordered logit as in Table 5
    dice_rec  = ifelse(dice == 6, 0, dice),
    card_rec  = ifelse(card == 6, 0, card),
    dice_rec  = ordered(dice_rec),
    card_rec  = ordered(card_rec),
    
    # Controls
    female           = gender1_W == 1,
    order_dice_first = `order1=W` == 0,
    education_years  = `education years`
  )

## ---- 1. Descriptive statistics ----

# 1.1 Basic descriptives by sample
desc_by_place <- dat %>%
  group_by(place_fac) %>%
  summarise(
    n              = n(),
    mean_age       = mean(age, na.rm = TRUE),
    sd_age         = sd(age, na.rm = TRUE),
    mean_educ      = mean(education_years, na.rm = TRUE),
    sd_educ        = sd(education_years, na.rm = TRUE),
    share_female   = mean(female, na.rm = TRUE),
    .groups = "drop"
  )

print(desc_by_place)

# 1.2 Dice and card reports by sample (means)
means_dice_card <- dat %>%
  group_by(place_fac) %>%
  summarise(
    mean_dice = mean(dice, na.rm = TRUE),
    sd_dice   = sd(dice, na.rm = TRUE),
    mean_card = mean(card, na.rm = TRUE),
    sd_card   = sd(card, na.rm = TRUE),
    .groups = "drop"
  )

print(means_dice_card)

## ---- 2. Distributions of reported numbers (1–6) ----

# 2.1 Dice: distribution overall and by sample
dist_dice <- dat %>%
  filter(!is.na(dice)) %>%
  count(place_fac, dice) %>%
  group_by(place_fac) %>%
  mutate(
    prop = n / sum(n)
  ) %>%
  ungroup()

print(dist_dice)

# 2.2 Card: distribution overall and by sample
dist_card <- dat %>%
  filter(!is.na(card)) %>%
  count(place_fac, card) %>%
  group_by(place_fac) %>%
  mutate(
    prop = n / sum(n)
  ) %>%
  ungroup()

print(dist_card)

# 2.3 Optional plots (Dice vs. uniform 1/6)
ggplot(dist_dice, aes(x = factor(dice), y = prop)) +
  geom_col(fill = "steelblue") +
  facet_wrap(~ place_fac) +
  geom_hline(yintercept = 1/6, linetype = "dashed", color = "red") +
  labs(x = "Reported number (dice)",
       y = "Proportion",
       title = "Dice reports by sample (line = uniform 1/6)") +
  theme_bw()

# 2.4 Optional plots (Card vs. uniform 1/6)
ggplot(dist_card, aes(x = factor(card), y = prop)) +
  geom_col(fill = "darkgreen") +
  facet_wrap(~ place_fac) +
  geom_hline(yintercept = 1/6, linetype = "dashed", color = "red") +
  labs(x = "Reported number (card)",
       y = "Proportion",
       title = "Card reports by sample (line = uniform 1/6)") +
  theme_bw()

## ---- 3. Simple tests against uniform distribution ----
# (Chi-square tests for deviation from uniform 1/6)

# Helper: function to run test for one variable and sample
chisq_uniform_by_place <- function(data, var_name) {
  # var_name: "dice" or "card"
  out_list <- list()
  for (pl in levels(data$place_fac)) {
    tmp <- data %>%
      filter(place_fac == pl, !is.na(.data[[var_name]]))
    obs <- table(tmp[[var_name]])
    exp <- rep(sum(obs) / 6, 6)  # uniform
    test <- suppressWarnings(chisq.test(obs, p = rep(1/6, 6)))
    out_list[[pl]] <- data.frame(
      place_fac = pl,
      var       = var_name,
      statistic = unname(test$statistic),
      df        = unname(test$parameter),
      p_value   = unname(test$p.value),
      N         = sum(obs)
    )
  }
  dplyr::bind_rows(out_list)
}

chisq_dice <- chisq_uniform_by_place(dat, "dice")
chisq_card <- chisq_uniform_by_place(dat, "card")

chisq_results <- bind_rows(chisq_dice, chisq_card)
print(chisq_results)

## ---- 4. Dice vs. card comparisons ----
# Example: mean difference in reports within subjects

# Paired t-test or Wilcoxon test, overall and by sample
paired_tests <- dat %>%
  filter(!is.na(dice), !is.na(card)) %>%
  group_by(place_fac) %>%
  summarise(
    mean_dice = mean(dice),
    mean_card = mean(card),
    # paired t-test
    t_stat    = t.test(dice, card, paired = TRUE)$statistic,
    p_t       = t.test(dice, card, paired = TRUE)$p.value,
    # Wilcoxon signed-rank
    W_stat    = suppressWarnings(wilcox.test(dice, card, paired = TRUE)$statistic),
    p_W       = suppressWarnings(wilcox.test(dice, card, paired = TRUE)$p.value),
    n         = n(),
    .groups = "drop"
  )

print(paired_tests)

## ---- 5. Ordered logit models (as in Table 5) ----

# 5.1 Dice version
m_dice <- MASS::polr(
  dice_rec ~ age + female + order_dice_first + place_fac,
  data = dat,
  Hess = TRUE
)

summary(m_dice)

# 5.2 Card version
m_card <- MASS::polr(
  card_rec ~ age + female + order_dice_first + place_fac,
  data = dat,
  Hess = TRUE
)

summary(m_card)

# 5.3 Extract coefficients in a compact table-like form
coef_dice <- cbind(
  Estimate = coef(m_dice),
  SE       = sqrt(diag(vcov(m_dice))),
  t_value  = coef(m_dice) / sqrt(diag(vcov(m_dice)))
)

coef_card <- cbind(
  Estimate = coef(m_card),
  SE       = sqrt(diag(vcov(m_card))),
  t_value  = coef(m_card) / sqrt(diag(vcov(m_card)))
)

print(coef_dice)
print(coef_card)

## ---- 6. Optional: simple “lying intensity” measures ----
# For each subject, define incentive rank (higher = more payoff)
# Here: numbers 1–5 increasing payoff, 6 gives 0 payoff.
# We can approximate "lying temptation" by the rank itself:
dat <- dat %>%
  mutate(
    dice_incentive = ifelse(dice == 6, 0, dice),  # same as dice_rec
    card_incentive = ifelse(card == 6, 0, card)   # same as card_rec
  )

# Compare mean incentive rank across samples and tasks
incentive_summary <- dat %>%
  group_by(place_fac) %>%
  summarise(
    mean_dice_incentive = mean(dice_incentive, na.rm = TRUE),
    mean_card_incentive = mean(card_incentive, na.rm = TRUE),
    .groups = "drop"
  )

print(incentive_summary)
