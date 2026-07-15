# =============================================================================
# MASTER SCRIPT
# R version: 4.6.0
# =============================================================================

gc()
rm(list = ls())

renv::restore(prompt = FALSE)

library(rmarkdown)
library(xfun)

source("R/run_script_project.R")

# =============================================================================
# PAPERS TO RUN
# =============================================================================

# Payzan-LeNestour et al. (2026)
run_script_project(
  script_path = "R/run_payzan_2026.R",
  log_file = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt"
)

# Payzan-LeNestour and Woodford (2022)
run_script_project(
  script_path = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R",
  log_file = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt"
)

# Huber and Huber (2020)
run_script_project(
  script_path = "R/run_huber_2020.R",
  log_file = "huberBadBankersNo2020/Huber2020_log.txt"
)

# Snijder et al. (2024)
run_script_project(
  script_path = "R/run_snijder_2024.R",
  log_file = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt"
)

# Ekström et al. (2025)
run_script_project(
  script_path = "ekstromMakingPromiseIncreases2025/MakingAPromise.R",
  log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt"
)

message("\n=== END SCRIPT ===\n")