# =============================================================================
# MASTER SCRIPT - Reproducibility Pipeline
# R version: 4.6.0
# =============================================================================

gc()
rm(list = ls())

renv::restore(prompt = FALSE)

# Load required packages for the master script
library(rmarkdown)
library(xfun)

# Load the reusable execution function
source("R/run_script_project.R")

# =============================================================================
# PAPERS TO RUN
# =============================================================================

# Payzan-LeNestour et al. (2026) - Stubborn Design
run_script_project(
  script_path = "payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R",
  log_file    = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
  base_dir    = "payzan-lenestourStubbornDesignNeurobiological/Reproducibility"   # <-- CLAVE
)

# Payzan-LeNestour and Woodford (2022) - Outlier Blindness
run_script_project(
  script_path = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R",
  log_file    = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt"
)

# Huber and Huber (2020) - Bad Bankers
run_script_project(
  script_path = "huberBadBankersNo2020/notebook.Rmd",   # Note: this is an Rmd
  log_file    = "huberBadBankersNo2020/Huber2020_log.txt"
)

# Snijder et al. (2024)
run_script_project(
  script_path = "snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R",
  log_file    = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt"
)

# Ekström et al. (2025)
run_script_project(
  script_path = "ekstromMakingPromiseIncreases2025/MakingAPromise.R",
  log_file    = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt"
)

message("\n=== END OF MASTER SCRIPT ===\n")