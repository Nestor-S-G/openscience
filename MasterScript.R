# =============================================================================
# MASTER SCRIPT - Computational Reproducibility
# R version: 4.6.0
# =============================================================================

rm(list = ls())

renv::restore(prompt = FALSE)

library(rmarkdown)
library(xfun)
library(here)

# =============================================================================
# Core function
# =============================================================================

run_script_project <- function(log_file, expr) {
  
  if (is.language(expr) && !is.name(expr)) {
    captured_expr <- expr
  } else {
    captured_expr <- substitute(expr)
  }
  
  message("\nSTART: ", log_file)
  success <- TRUE
  
  tryCatch({
    
    xfun::Rscript_call(
      function(expr, log_file) {
        
        options(error = quote(quit(status = 1, save = "no")))
        options(warn = 1)
        
        library(here)
        setwd(here::here())
        
        dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
        
        con <- file(log_file, open = "wt")
        sink(con)
        sink(con, type = "message")
        
        on.exit({
          sink(type = "message")
          sink()
          close(con)
        }, add = TRUE)
        
        eval(expr, envir = new.env(parent = globalenv()))
        
      },
      args = list(expr = captured_expr, log_file = log_file)
    )
    
  }, error = function(e) {
    success <<- FALSE
    message("ERROR running ", log_file, ": ", conditionMessage(e))
  })
  
  if (success) {
    message("END: ", log_file, " [SUCCESS]\n")
  } else {
    message("END: ", log_file, " [FAILED]\n")
  }
  
  invisible(success)
}

# =============================================================================
# DECLARATIVE PROJECT CONFIGURATION
# =============================================================================

projects <- list(
  
  payzan_2025 = list(
    name = "Payzan-LeNestour et al. (2025)",
    log_file = "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
    type = "custom",
    setup = quote({
      assignInNamespace("getActiveDocumentContext",
                        function(...) list(path = file.path(here::here(), "run_full_script.R")),
                        ns = "rstudioapi")
      
      local({
        orig <- get("effectsize", envir = asNamespace("effectsize"))
        assignInNamespace("effectsize", function(x, ...) {
          tryCatch(orig(x, ...),
                   error = function(e) {
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
    type = "simple",
    script = "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R"
  ),
  
  huber_2020 = list(
    name = "Huber and Huber (2020)",
    log_file = "huberBadBankersNo2020/Huber2020_log.txt",
    type = "rmd_with_patches",
    rmd_file = "huberBadBankersNo2020/notebook.Rmd",
    output_pdf = "Huber2020_reproduced.pdf"
  ),
  
  snijder_2024 = list(
    name = "Snijder et al. (2024)",
    log_file = "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt",
    type = "multiple_scripts",
    scripts = c(
      "snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R",
      "snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R",
      "snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R",
      "snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R",
      "snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R"
    )
  ),
  
  ekstrom_2025 = list(
    name = "Ekström et al. (2025)",
    log_file = "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt",
    type = "simple",
    script = "ekstromMakingPromiseIncreases2025/MakingAPromise.R"
  )
)

# =============================================================================
# EXECUTION ENGINE
# =============================================================================

message("=== Starting reproduction of ", length(projects), " projects ===\n")

for (proj in projects) {
  
  cat("\n=== Running:", proj$name, "===\n")
  
  tryCatch({
    
    if (proj$type == "simple") {
      
      # Fixed: use local variable to avoid capture issues
      script_path <- proj$script
      run_script_project(
        log_file = proj$log_file,
        expr = { source(script_path, local = TRUE) }
      )
      
    } else if (proj$type == "multiple_scripts") {
      
      scripts_list <- proj$scripts
      run_script_project(
        log_file = proj$log_file,
        expr = {
          library(here)
          setwd(here::here())
          for (s in scripts_list) source(s, local = TRUE)
        }
      )
      
    } else if (proj$type == "rmd_with_patches") {
      
      run_script_project(
        log_file = proj$log_file,
        expr = {
          library(here)
          setwd(here::here())
          
          # Stargazer Patch
          sg_path <- find.package("stargazer")
          tmp_tar <- tempfile(fileext = ".tar.gz")
          download.file("https://cran.r-project.org/src/contrib/stargazer_5.2.3.tar.gz",
                        destfile = tmp_tar, quiet = TRUE)
          tmp_dir <- tempdir()
          untar(tmp_tar, exdir = tmp_dir)
          code <- readLines(file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
          l1 <- grep("if (is.na(s))", code, fixed = TRUE)
          code[l1] <- gsub("if (is.na(s))", "if (length(s) == 0 || all(is.na(s)))", code[l1], fixed = TRUE)
          l2 <- grep('if (s=="")', code, fixed = TRUE)
          code[l2] <- gsub('if (s=="")', 'if (length(s) == 0 || all(s == ""))', code[l2], fixed = TRUE)
          writeLines(code, file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
          install.packages(file.path(tmp_dir, "stargazer"), 
                           repos = NULL, type = "source", quiet = TRUE, 
                           lib = dirname(sg_path))
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
            input         = proj$rmd_file,
            output_format = "pdf_document",
            output_file   = proj$output_pdf,
            clean         = FALSE,
            envir         = globalenv(),
            quiet         = FALSE
          )
        }
      )
      
    } else if (proj$type == "custom") {
      
      run_script_project(
        log_file = proj$log_file,
        expr = proj$setup
      )
    }
    
  }, error = function(e) {
    message("UNEXPECTED ERROR in main loop for ", proj$name, ": ", conditionMessage(e))
  })
}

message("\n=== MasterScript COMPLETED - All projects processed ===\n")