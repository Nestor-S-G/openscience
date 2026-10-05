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
  log_file = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt",
  expr = {
    source("payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R", local = TRUE)
  }
)

# Huber and Huber (2020)
run_script_project(
  log_file = "huberBadBankersNo2020/huber2020_log.txt",
  expr = {
    log_con <- file("huberBadBankersNo2020/huber2020_log.txt", open = "wt")
    sink(log_con, type = "output")
    sink(log_con, type = "message")

    rmarkdown::render(
      input = "huberBadBankersNo2020/notebook.Rmd",
      output_format = "html_document",
      quiet = FALSE
    )

    sink(type = "message")
    sink(type = "output")
    close(log_con)
  }
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
  log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt",
  expr = {
    source("ekstromMakingPromiseIncreases2025/MakingAPromise.R", local = TRUE)
  }
)

message("\n=== END SCRIPT ===\n")
