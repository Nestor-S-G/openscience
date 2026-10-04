# =============================================================================
# MASTER SCRIPT
# =============================================================================

gc()
rm(list = ls())

#Restore the project-specific R package library managed by renv
renv::restore(prompt = FALSE)

#Load required packages
library(rmarkdown)
library(xfun)

#Source the helper function that runs each project
source("R/run_script_project.R")

# =============================================================================
# PAPERS TO RUN
# =============================================================================

# Payzan-LeNestour et al. (2026)
run_script_project(
  log_file = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
  expr = {
    # Mock rstudioapi so scripts that rely on the active document path still work
    assignInNamespace("getActiveDocumentContext",
                      function(...) list(path = file.path(here::here(), "run_full_script.R")),
                      ns = "rstudioapi")

    # Wrap effectsize() in a tryCatch so a single failure does not stop the whole script
    local({
      orig <- get("effectsize", envir = asNamespace("effectsize"))
      assignInNamespace("effectsize", function(x, ...) {
        tryCatch(orig(x, ...), error = function(e) {
          message("effectsize error (skipped): ", conditionMessage(e))
          invisible(NULL)
        })
      }, ns = "effectsize")
    })

    # Execute the paper's main reproducibility script
    source("payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R", local = TRUE)
  }
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
  log_file = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt",
  expr = {
    library(here)
    setwd(here::here())

    # Sequential execution of data analysis files
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R", local = TRUE)
  }
)

# Ekström et al. (2025)
run_script_project(
  script_path = "ekstromMakingPromiseIncreases2025/MakingAPromise.R",
  log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt"
)

message("\n=== END SCRIPT ===\n")
