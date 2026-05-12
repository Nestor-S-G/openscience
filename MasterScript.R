#Master script
# R version: 4.6.0
gc()
rm(list = ls())

renv::restore()

#Libraries
library(rmarkdown)
library(xfun)

run_script_project <- function(
    expr,
    log_file
) {
  
  expr <- substitute(expr)
  message("\nSTART: ", log_file)
  try(
    
    xfun::Rscript_call(
      
      function(expr, log_file) {
        
        # ── Evitar browser interactivo en sesión hija ──
        options(error = quote(quit(status = 1)))
        # ──────────────────────────────────────────────
        
        library(here)
        
        setwd(here::here())
        
        dir.create(
          dirname(log_file),
          recursive = TRUE,
          showWarnings = FALSE
        )
        
        con <- file(log_file, open = "wt")
        
        sink(con)
        sink(con, type = "message")
        
        on.exit({
          
          sink(type = "message")
          sink()
          
          close(con)
          
        }, add = TRUE)
        
        eval(
          expr,
          envir = new.env(parent = globalenv())
        )
        
      },
      
      args = list(
        expr = expr,
        log_file = log_file
      )
      
    ),
    
    silent = FALSE
  )
  message("END: ", log_file)
}

# Payzan-LeNestour et al. (2025)
run_script_project(
  
  log_file =
    "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt",
  
  expr = {
    
    assignInNamespace(
      "getActiveDocumentContext",
      function(...) list(
        path = file.path(here::here(), "run_full_script.R")
      ),
      ns = "rstudioapi"
    )
    
    local({
      orig <- get("effectsize", envir = asNamespace("effectsize"))
      assignInNamespace(
        "effectsize",
        function(x, ...) {
          tryCatch(
            orig(x, ...),
            error = function(e) {
              message("effectsize error (skipped): ", conditionMessage(e))
              invisible(NULL)
            }
          )
        },
        ns = "effectsize"
      )
    })
    
    source(
      "payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R",
      local = TRUE
    )
    
  }
  
)

# Payzan-LeNestour and Woodford (2022)
run_script_project(
  
  log_file =
    "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt",
  
  expr = {
    
    source(
      "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R",
      local = TRUE
    )
    
  }
  
)

# Huber and Huber (2020)
local({
  # ── PARCHE STARGAZER: compatibilidad con R 4.x ────────────────────────────
  sg_path <- find.package("stargazer")
  tmp_tar <- tempfile(fileext = ".tar.gz")
  download.file(
    "https://cran.r-project.org/src/contrib/stargazer_5.2.3.tar.gz",
    destfile = tmp_tar, quiet = TRUE)
  tmp_dir <- tempdir()
  untar(tmp_tar, exdir = tmp_dir)
  code <- readLines(file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
  l1 <- grep("if (is.na(s))", code, fixed = TRUE)
  code[l1] <- gsub("if (is.na(s))",
                   "if (length(s) == 0 || all(is.na(s)))", code[l1], fixed = TRUE)
  l2 <- grep('if (s=="")', code, fixed = TRUE)
  code[l2] <- gsub('if (s=="")',
                   'if (length(s) == 0 || all(s == ""))', code[l2], fixed = TRUE)
  writeLines(code, file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
  install.packages(file.path(tmp_dir, "stargazer"),
                   repos = NULL, type = "source", quiet = TRUE,
                   lib = dirname(sg_path))
  cat("stargazer parcheado para R 4.x\n")
  # ──────────────────────────────────────────────────────────────────────────
  
  try(
    xfun::Rscript_call(function() {
      library(here)
      setwd(here::here())
      assignInNamespace("tbl_df", tibble::as_tibble, ns = "dplyr")
      log_file <- "huberBadBankersNo2020/Huber2020_render_log.txt"
      dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
      con <- file(log_file, open = "wt")
      sink(con)
      sink(con, type = "message")
      on.exit({ sink(type = "message"); sink(); sink(); close(con) }, add = TRUE)
      unlockBinding("ggsave", asNamespace("ggplot2"))
      original_ggsave <- ggplot2::ggsave
      assign("ggsave", function(filename, ...) {
        dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
        original_ggsave(filename, ...)
      }, envir = asNamespace("ggplot2"))
      lockBinding("ggsave", asNamespace("ggplot2"))
      rmarkdown::render(
        input         = "huberBadBankersNo2020/notebook.Rmd",
        output_format = "pdf_document",
        output_file   = "Huber2020_reproduced.pdf",
        clean         = FALSE,
        envir         = globalenv(),
        quiet         = FALSE
      )
    }),
    silent = FALSE
  )
})

# Snijder et al. (2024)
run_script_project(
  
  log_file =
    "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt",
  
  expr = {
    
    library(here)
    setwd(here::here())
    
    # Ejecutar scripts en orden (manteniendo el orden original)
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R",
           local = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R",
           local = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R",
           local = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R",
           local = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R",
           local = TRUE)
    
  }
  
)

# Ekström et al. (2025), (R part)
run_script_project(
  
  log_file =
    "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt",
  
  expr = {
    
    source(
      "ekstromMakingPromiseIncreases2025/MakingAPromise.R",
      local = TRUE
    )
    
  }
  
)