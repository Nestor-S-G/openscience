# ============================================================
# REPRODUCTION SCRIPT (ROBUST TO DIFFERENT ID NAMES)
# Barrafrem et al. (2021)
# Extended for more complete reproduction
# ============================================================
if (!require("pacman")) install.packages("pacman")
pacman::p_load(haven, tidyverse, lme4, broom.mixed, ggplot2, binom, effectsize)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------
main_data <- read_dta("OutcomeEditingData.dta") %>%
  rename_with(tolower)
student_data <- read_dta("OutcomeEditingDataRandomizedStudent.dta") %>%
  rename_with(tolower)

# ------------------------------------------------------------
# 2. Harmonize respondent ID
# ------------------------------------------------------------
standardize_id <- function(df) {
  id_candidates <- c("idcode", "id", "respondent", "subject", "respondentid", "participant", "pid", "subjectid", "id_code", "resp", "resp_id", "responseid")
  id_found <- id_candidates[id_candidates %in% names(df)][1]
  
  if (is.na(id_found)) {
    print("Available columns:")
    print(names(df))
    stop("No respondent ID found in dataset.")
  }
  
  df %>% rename(idcode = all_of(id_found))
}
main_data <- standardize_id(main_data)
student_data <- standardize_id(student_data)

# ------------------------------------------------------------
# 3. Recode dependent variable
# DV = integrate outcomes (1 = integrate, 0 = segregate)
# ------------------------------------------------------------
recode_outcomes <- function(df) {
  df %>%
    mutate(across(
      starts_with(c("fin_", "soc_")),
      ~ as.numeric(as_factor(.x) == "combine")
    ))
}
main_data <- recode_outcomes(main_data)
student_data <- recode_outcomes(student_data)

# ------------------------------------------------------------
# 4. Reshape to long format
# Add education assuming variable name 'education'
# If categorical, convert to factor if needed
# ------------------------------------------------------------
to_long <- function(df) {
  fixed_cols <- c("idcode", "age", "female", "numeracy", "education")
  missing_cols <- setdiff(fixed_cols, names(df))
  if (length(missing_cols) > 0) {
    warning(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
  }
  df %>%
    select(any_of(fixed_cols), starts_with(c("fin_", "soc_"))) %>%
    pivot_longer(
      cols = starts_with(c("fin_", "soc_")),
      names_to = "scenario",
      values_to = "integrate"
    ) %>%
    separate(scenario, into = c("domain", "type"), sep = "_") %>%
    mutate(
      domain = factor(domain, levels = c("fin", "soc")),
      type = factor(
        type,
        levels = c("gains", "losses", "mixloss", "mixgain"),
        labels = c("Two Gains", "Two Losses", "Mixed Loss", "Mixed Gain")
      ),
      education = if ("education" %in% names(.)) factor(education) else NULL
    )
}
main_long <- to_long(main_data)
student_long <- to_long(student_data)

# ------------------------------------------------------------
# 5. Reproduce Fig 1: Proportions of integration with 95% CI
# Binomial tests vs 50%, Cohen's g = |prop - 0.5|
# ------------------------------------------------------------
prop_summary <- function(long_df, dataset_name) {
  summary <- long_df %>%
    group_by(domain, type) %>%
    summarise(
      n = sum(!is.na(integrate)),
      integrate_count = sum(integrate, na.rm = TRUE),
      prop = mean(integrate, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    mutate(
      se = sqrt(prop * (1 - prop) / n),
      ci_low = prop - qnorm(0.975) * se,
      ci_high = prop + qnorm(0.975) * se,
      cohen_g = abs(prop - 0.5)
    )
  
  # Binomial tests
  binom_results <- summary %>%
    rowwise() %>%
    mutate(
      binom_test = list(binom.test(integrate_count, n, p = 0.5)),
      p_value = binom_test$p.value
    ) %>%
    select(-binom_test)
  
  print(paste("Proportions and tests for", dataset_name))
  print(binom_results)
  
  # Plot Fig 1
  ggplot(summary, aes(x = type, y = prop, fill = domain)) +
    geom_bar(stat = "identity", position = position_dodge()) +
    geom_errorbar(aes(ymin = ci_low, ymax = ci_high), position = position_dodge(0.9), width = 0.25) +
    geom_hline(yintercept = 0.5, linetype = "dashed") +
    labs(title = paste("Proportion Integrating Outcomes -", dataset_name),
         y = "Proportion", x = "Outcome Type", fill = "Domain") +
    theme_minimal() +
    scale_fill_manual(values = c("fin" = "darkgray", "soc" = "lightgray"))
}

prop_summary(main_long, "Main Sample")
# prop_summary(student_long, "Student Sample")  # Uncomment if needed

# ------------------------------------------------------------
# 6. Domain comparisons: McNemar tests, paired t-tests for d_z
# For each type, compare fin vs soc integrate
# Need wide format
# ------------------------------------------------------------
domain_comparisons <- function(wide_df, dataset_name) {
  types <- c("gains", "losses", "mixloss", "mixgain")
  results <- list()
  
  for (t in types) {
    fin_var <- paste0("fin_", t)
    soc_var <- paste0("soc_", t)
    
    paired_data <- wide_df %>%
      select(all_of(c(fin_var, soc_var))) %>%
      drop_na()
    
    # McNemar test
    tab <- table(paired_data[[fin_var]], paired_data[[soc_var]])
    mcnemar <- mcnemar.test(tab)
    
    # Paired t-test for d_z
    diff <- paired_data[[fin_var]] - paired_data[[soc_var]]
    t_test <- t.test(diff, mu = 0)
    d_z <- effectsize::cohens_d(diff, mu = 0, paired = TRUE)$Cohens_d
    
    results[[t]] <- list(
      mcnemar_p = mcnemar$p.value,
      t_p = t_test$p.value,
      d_z = abs(d_z),
      mean_diff = mean(diff)
    )
  }
  
  print(paste("Domain comparisons for", dataset_name))
  print(results)
}

domain_comparisons(main_data, "Main Sample")
# domain_comparisons(student_data, "Student Sample")

# ------------------------------------------------------------
# 7. Individual level consistency across domains
# % same choice for each type, overall % consistent all four
# ------------------------------------------------------------
consistency_analysis <- function(wide_df, dataset_name) {
  types <- c("gains", "losses", "mixloss", "mixgain")
  
  # Per type
  per_type <- sapply(types, function(t) {
    fin <- paste0("fin_", t)
    soc <- paste0("soc_", t)
    mean(wide_df[[fin]] == wide_df[[soc]], na.rm = TRUE)
  })
  names(per_type) <- types
  
  # Overall consistent all four
  consistent_all <- wide_df %>%
    rowwise() %>%
    mutate(
      consistent = (fin_gains == soc_gains) &
        (fin_losses == soc_losses) &
        (fin_mixloss == soc_mixloss) &
        (fin_mixgain == soc_mixgain)
    ) %>%
    pull(consistent) %>%
    mean(na.rm = TRUE)
  
  print(paste("Consistency across domains for", dataset_name))
  print(per_type)
  print(paste("Overall consistent all types:", consistent_all))
}

consistency_analysis(main_data, "Main Sample")

# ------------------------------------------------------------
# 8. Reproduce Fig 2: Bubble graphs for cross-domain choices per type
# ------------------------------------------------------------
plot_bubble <- function(wide_df, type_name) {
  fin_var <- paste0("fin_", type_name)
  soc_var <- paste0("soc_", type_name)
  
  counts <- wide_df %>%
    count(!!sym(fin_var), !!sym(soc_var)) %>%
    mutate(
      fin = factor(!!sym(fin_var), levels = c(0,1), labels = c("Segregate Fin", "Integrate Fin")),
      soc = factor(!!sym(soc_var), levels = c(0,1), labels = c("Segregate Soc", "Integrate Soc"))
    )
  
  ggplot(counts, aes(x = fin, y = soc, size = n)) +
    geom_point(alpha = 0.6) +
    scale_size(range = c(1, 20)) +
    labs(title = paste("Cross-Domain Choices for", gsub("_", " ", type_name)),
         size = "Count") +
    theme_minimal()
}

# Example for one type; repeat for others
plot_bubble(main_data, "gains")

# ------------------------------------------------------------
# 9. % Consistent with theoretical models
# For each domain separately
# ------------------------------------------------------------
model_consistency <- function(long_df, domain_filter, dataset_name) {
  wide_dom <- long_df %>%
    filter(domain == domain_filter) %>%
    pivot_wider(names_from = type, values_from = integrate) %>%
    rename_with(~ tolower(gsub(" ", "_", .)), .cols = -idcode)
  
  n_total <- nrow(wide_dom)
  
  # Renewable: segregate gains (0), segregate losses (0), integrate mixed (1,1)
  renewable <- wide_dom %>%
    filter(two_gains == 0 & two_losses == 0 & mixed_loss == 1 & mixed_gain == 1) %>%
    nrow() / n_total
  
  # Hedonic: segregate gains (0), integrate losses (1), integrate mixed gain (1), mixed loss either
  hedonic <- wide_dom %>%
    filter(two_gains == 0 & two_losses == 1 & mixed_gain == 1) %>%
    nrow() / n_total  # Includes both for mixed_loss
  
  # Additional for social: segregate any with gain, integrate losses
  # I.e., two_gains=0, mixed_loss=0, mixed_gain=0, two_losses=1
  social_pattern <- wide_dom %>%
    filter(two_gains == 0 & two_losses == 1 & mixed_loss == 0 & mixed_gain == 0) %>%
    nrow() / n_total
  
  print(paste("Model consistency for", domain_filter, "domain in", dataset_name))
  print(paste("Renewable:", renewable))
  print(paste("Hedonic:", hedonic))
  if (domain_filter == "soc") print(paste("Social pattern:", social_pattern))
}

model_consistency(main_long, "fin", "Main Sample")
model_consistency(main_long, "soc", "Main Sample")

# ------------------------------------------------------------
# 10. Table 2 — Main sample (with education)
# ------------------------------------------------------------
has_numeracy <- function(data) "numeracy" %in% names(data)
has_education <- function(data) "education" %in% names(data)
model_formula <- function(has_num, has_edu) {
  base <- "integrate ~ type"
  if (has_num) base <- paste(base, "* numeracy")
  base <- paste(base, "+ age + female")
  if (has_edu) base <- paste(base, "+ education")
  base <- paste(base, "+ (1 | idcode)")
  as.formula(base)
}

model_fin <- lmer(
  model_formula(has_numeracy(filter(main_long, domain == "fin")), has_education(filter(main_long, domain == "fin"))),
  data = filter(main_long, domain == "fin")
)
model_soc <- lmer(
  model_formula(has_numeracy(filter(main_long, domain == "soc")), has_education(filter(main_long, domain == "soc"))),
  data = filter(main_long, domain == "soc")
)
tidy(model_fin, effects = "fixed", conf.int = TRUE)
tidy(model_soc, effects = "fixed", conf.int = TRUE)

# ------------------------------------------------------------
# 11. Robustness check — Student sample
# ------------------------------------------------------------
student_fin <- lmer(
  model_formula(has_numeracy(filter(student_long, domain == "fin")), has_education(filter(student_long, domain == "fin"))),
  data = filter(student_long, domain == "fin")
)
student_soc <- lmer(
  model_formula(has_numeracy(filter(student_long, domain == "soc")), has_education(filter(student_long, domain == "soc"))),
  data = filter(student_long, domain == "soc")
)

# Custom tidy for student models to handle vcov issues
safe_tidy <- function(model) {
  estimates <- lme4::fixef(model)
  terms <- names(estimates)
  vcov_mat <- tryCatch(as.matrix(lme4::vcov(model, full = TRUE)), 
                       warning = function(w) matrix(NA, nrow = length(estimates), ncol = length(estimates)),
                       error = function(e) matrix(NA, nrow = length(estimates), ncol = length(estimates)))
  std.errors <- if (!any(is.na(vcov_mat))) sqrt(diag(vcov_mat)) else rep(NA, length(estimates))
  statistics <- estimates / std.errors
  df <- data.frame(
    term = terms,
    estimate = estimates,
    std.error = std.errors,
    statistic = statistics
  )
  df
}

safe_tidy(student_fin)
safe_tidy(student_soc)

# ============================================================
# END OF SCRIPT
# ============================================================