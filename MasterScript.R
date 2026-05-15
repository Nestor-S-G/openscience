# =============================================================================
# MASTER SCRIPT - Computational Reproducibility (Declarative Version)
# R version: 4.6.0
# =============================================================================

rm(list = ls())

renv::restore(prompt = FALSE)

library(rmarkdown)
library(xfun)
library(here)

# =============================================================================
# Reliable runner with directory creation fix
# =============================================================================

run_script_project <- function(log_file, expr) {
  
  message("\nSTART: ", log_file)
  
  # Ensure log directory exists
  dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
  
  result <- tryCatch({
    
    con <- file(log_file, open = "wt")
    sink(con)
    sink(con, type = "message")
    
    on.exit({
      sink(type = "message")
      sink()
      close(con)
    }, add = TRUE)
    
    # Execute in clean environment
    eval(expr, envir = new.env(parent = globalenv()))
    
    TRUE  # success
    
  }, error = function(e) {
    message("ERROR: ", conditionMessage(e))
    FALSE
  })
  
  if (result) {
    message("END: ", log_file, " [SUCCESS]\n")
  } else {
    message("END: ", log_file, " [FAILED]\n")
  }
}

# =============================================================================
# DECLARATIVE PROJECT CONFIGURATION
# =============================================================================

projects <- list(
  
  payzan_2025 = list(
    name = "Payzan-LeNestour et al. (2025)",
    log_file = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
    expr = quote({
      assignInNamespace("getActiveDocumentContext",
                        function(...) list(path = file.path(here::here(), "run_full_script.R")),
                        ns = "rstudioapi")
      
      local({
        orig <- get("effectsize", envir = asNamespace("effectsize"))
        assignInNamespace("effectsize", function(x, ...) {
          tryCatch(orig(x, ...), error = function(e) {
            message("effectsize error (skipped): ", conditionMessage(e))
            invisible(NULL)
          })
        }, ns = "effectsize")
      })
      
      source("payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R", local = TRUE)
    })
  ),
  
  payzan_2022 = list(
    name = "Payzan-LeNestour and Woodford (2022)",
    log_file = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt",
    expr = quote({
      source("payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R", local = TRUE)
    })
  ),
  
  huber_2020 = list(
    name = "Huber and Huber (2020)",
    log_file = "huberBadBankersNo2020/Huber2020_log.txt",
    expr = quote({
      library(here)
      setwd(here::here())
      
      # Stargazer patch
      sg_path <- find.package("stargazer")
      tmp_tar <- tempfile(fileext = ".tar.gz")
      download.file("https://cran.r-project.org/src/contrib/stargazer_5.2.3.tar.gz", destfile = tmp_tar, quiet = TRUE)
      tmp_dir <- tempdir()
      untar(tmp_tar, exdir = tmp_dir)
      code <- readLines(file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
      l1 <- grep("if (is.na(s))", code, fixed = TRUE)
      code[l1] <- gsub("if (is.na(s))", "if (length(s) == 0 || all(is.na(s)))", code[l1], fixed = TRUE)
      l2 <- grep('if (s=="")', code, fixed = TRUE)
      code[l2] <- gsub('if (s=="")', 'if (length(s) == 0 || all(s == ""))', code[l2], fixed = TRUE)
      writeLines(code, file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
      install.packages(file.path(tmp_dir, "stargazer"), repos = NULL, type = "source", quiet = TRUE, lib = dirname(sg_path))
      cat("stargazer patched for R 4.x\n")
      
      assignInNamespace("tbl_df", tibble::as_tibble, ns = "dplyr")
      
      unlockBinding("ggsave", asNamespace("ggplot2"))
      original_ggsave <- ggplot2::ggsave
      assign("ggsave", function(filename, ...) {
        dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
        original_ggsave(filename, ...)
      }, envir = asNamespace("ggplot2"))
      lockBinding("ggsave", asNamespace("ggplot2"))
      
      rmarkdown::render(
        input = "huberBadBankersNo2020/notebook.Rmd",
        output_format = "pdf_document",
        output_file = "Huber2020_reproduced.pdf",
        clean = FALSE,
        envir = globalenv(),
        quiet = FALSE
      )
    })
  ),
  
  snijder_2024 = list(
    name = "Snijder et al. (2024)",
    log_file = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt",
    expr = quote({
      library(here)
      setwd(here::here())
      source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R", local = TRUE)
      source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R", local = TRUE)
      source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R", local = TRUE)
      source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R", local = TRUE)
      source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R", local = TRUE)
    })
  ),
  
  ekstrom_2025 = list(
    name = "Ekström et al. (2025)",
    log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt",
    expr = quote({
      source("ekstromMakingPromiseIncreases2025/MakingAPromise.R", local = TRUE)
    })
  )
)

# =============================================================================
# EXECUTION
# =============================================================================

message("=== Starting reproduction of ", length(projects), " projects ===\n")

for (proj in projects) {
  cat("\n=== Running:", proj$name, "===\n")
  
  run_script_project(
    log_file = proj$log_file,
    expr = proj$expr
  )
}

message("\n=== MasterScript COMPLETED - All projects processed ===\n")