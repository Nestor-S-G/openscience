# =============================================================================
# MASTER SCRIPT
#
# This script orchestrates the automated reproducibility pipeline across multiple research projects.
# Each paper is executed in an isolated process using `run_script_project()`, which captures console output and errors
# into project-specific log files via `log_file` and executes code blocks through `path`.
#
# Standard projects directly source their main `.R` scripts within `path`.
# Specific projects require custom setups: Huber and Huber (2020) uses `rmarkdown::render()` to process an `.Rmd` notebook into HTML.
# =============================================================================

gc()
rm(list = ls())

#Restore the project-specific R package library managed by renv
renv::restore(prompt = FALSE)

#Source the helper function that runs each project
source("R/run_script_project.R")

# =============================================================================
# PAPERS TO RUN
# =============================================================================

results <- list()

# Payzan-LeNestour et al. (2026)
results[["Payzan-LeNestour et al. (2026)"]] <- run_script_project(
  log_file = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
  path = {
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

    # Run the paper's main reproducibility script
    source("payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R", local = TRUE)
  }
)

# Payzan-LeNestour and Woodford (2022)
results[["Payzan-LeNestour and Woodford (2022)"]] <- run_script_project(
  path = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R",
  log_file = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt"
)

# Huber and Huber (2020)
results[["Huber and Huber (2020)"]] <- run_script_project(
  log_file = "huberBadBankersNo2020/huber2020_log.txt",
  path = {
    dir.create("git_data/graphs", recursive = TRUE, showWarnings = FALSE)
    dir.create("git_latex/graphs", recursive = TRUE, showWarnings = FALSE)

    rmarkdown::render(
      input = "huberBadBankersNo2020/notebook.Rmd",
      output_format = "html_document",
      quiet = FALSE
    )
  }
)

# Snijder et al. (2024)
results[["Snijder et al. (2024)"]] <- run_script_project(
  log_file = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt",
  path = {
    # Sequential execution of data analysis files
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R", local = TRUE)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R", local = TRUE)
  }
)

results[["Ekström et al. (2025)"]] <- run_script_project(
  path = "ekstromMakingPromiseIncreases2025/MakingAPromise.R",
  log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt"
)

# =============================================================================
# SUMMARY OF RESULTS
# =============================================================================

message("\n=================================================================")
message("Summary:")
message("=================================================================")
for (paper in names(results)) {
  res_status <- if (isTRUE(results[[paper]])) "SUCCESS" else "FAILED"
  message(sprintf(" - %-45s: %s", paper, res_status))
}
message("=================================================================\n")

message("\n=== END SCRIPT ===\n")
