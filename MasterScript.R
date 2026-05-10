#Master script
# R version: 4.6.0
gc()
rm(list = ls())

renv::restore()

#Libraries
library(rmarkdown)
library(here)
library(xfun)

# Payzan-LeNestour et al. (2025)
try(
  xfun::Rscript_call(function() {
    
    library(here)
    setwd(here::here())
    
    log_file <- "payzan-lenestourStubbornDesignNeurobiological/Stubborn_log.txt"
    dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
    con <- file(log_file, open = "wt")
    sink(con, type = "message")  # primero stderr
    sink(con)                     # luego stdout
    on.exit({
      sink(type = "message")
      sink()
      close(con)
    }, add = TRUE)
    
    assignInNamespace(
      "getActiveDocumentContext",
      function(...) list(path = file.path(here::here(), "run_full_script.R")),
      ns = "rstudioapi"
    )
    
    source("payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R",
           local = TRUE)
    
  }),
  silent = FALSE
)

# Payzan-LeNestour and Woodford (2022)
try(
  xfun::Rscript_call(function() {
    
    library(here)
    setwd(here::here())
    
    log_file <- "payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier_log.txt"
    
    # Crear carpeta si no existe (no el archivo)
    dir.create(dirname(log_file),
               recursive = TRUE,
               showWarnings = FALSE)
    
    con <- file(log_file, open = "wt")
    
    sink(con)
    sink(con, type = "message")
    
    on.exit({
      sink(type = "message")
      sink()
      sink()
      close(con)
    }, add = TRUE)
    
    source("payzan-lenestourOutlierBlindnessNeurobiological2022/Outlier.R", local = TRUE)
    
  }),
  silent = FALSE
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
try(
  xfun::Rscript_call(function() {
    
    log_file <- "snijderDecisionmakersSelfservinglyNavigate2024/Snijder2024_log.txt"
    con <- file(log_file, open = "wt")
    
    # Redirigir stdout y stderr
    sink(con)
    sink(con, type = "message")
    
    on.exit({
      sink(type = "message")
      sink()
      close(con)
    }, add = TRUE)
    library(here)
    setwd(here::here())
    
    # Ejecutar scripts con impresión explícita
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R",
           local = TRUE, echo = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R",
           local = TRUE, echo = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R",
           local = TRUE, echo = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R",
           local = TRUE, echo = TRUE)
    
    source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R",
           local = TRUE, echo = TRUE)
    
  }),
  silent = FALSE
)

# Ekström et al. (2025), (R part)
try(
  xfun::Rscript_call(function() {
    
    log_file <- "ekstromMakingPromiseIncreases2025/MakingAPromise_log.txt"
    
    # Abrir conexión de log
    con <- file(log_file, open = "wt")
    
    # Redirigir stdout y stderr
    sink(con)
    sink(con, type = "message")
    
    on.exit({
      sink(type = "message")
      sink()
      close(con)
    }, add = TRUE)
    
    library(here)
    setwd(here::here())
    
    source("ekstromMakingPromiseIncreases2025/MakingAPromise.R", local = TRUE)
    
  }),
  silent = FALSE
)
