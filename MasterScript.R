#Master script
# R version: 4.5.3
gc()
rm(list = ls())

renv::restore()

#Libraries
library(rmarkdown)
library(here)
library(xfun)

if (FALSE) {
  
  # Script Payzan-LeNestour et al. (2024)
  root <- here()
  setwd(root)
  source("Article4_Stubborn/run_full_script.R")

}

# Script Payzan-LeNestour and Woodford (2022)
try(
  xfun::Rscript_call(function() {
    
    library(here)
    setwd(here::here())
    
    log_file <- "Article1_Outlier/Outlier_log.txt"
    
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
    
    source("Article1_Outlier/Outlier.R", local = TRUE)
    
  }),
  silent = FALSE
)

# Script Huber and Huber (2020)
try(
  xfun::Rscript_call(function() {
    
    library(here)
    setwd(here::here())
    
    log_file <- "Article5_BadBankers/Huber2020_render_log.txt"
    
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
    
    # Wrapper para ggsave (sin modificar el código del artículo)
    unlockBinding("ggsave", asNamespace("ggplot2"))
    original_ggsave <- ggplot2::ggsave
    
    assign("ggsave", function(filename, ...) {
      dir.create(dirname(filename),
                 recursive = TRUE,
                 showWarnings = FALSE)
      original_ggsave(filename, ...)
    }, envir = asNamespace("ggplot2"))
    
    lockBinding("ggsave", asNamespace("ggplot2"))
    
    # ← SIN tryCatch (crítico para diagnóstico reproducible)
    rmarkdown::render(
      input         = "Article5_BadBankers/notebook.Rmd",
      output_format = "pdf_document",
      output_file   = "Huber2020_reproduced.pdf",
      clean         = FALSE,
      envir         = globalenv(),
      quiet         = FALSE
    )
    
  }),
  silent = FALSE
)


# #Script Snijder et al. (2024)
try(
  xfun::Rscript_call(function() {
    
    log_file <- "Article7_DecisionMakers/Snijder2024_log.txt"
    con <- file(log_file, open = "wt")
    
    # Redirigir stdout y stderr
    sink(con)
    sink(con, type = "message")
    
    on.exit({
      sink(type = "message")
      sink()
      close(con)
    }, add = TRUE)
    
    setwd(here::here())
    
    # Ejecutar scripts con impresión explícita
    source("Article7_DecisionMakers/scripts/data_analysis/models.R",
           local = TRUE, echo = TRUE)
    
    source("Article7_DecisionMakers/scripts/data_analysis/partner choice.R",
           local = TRUE, echo = TRUE)
    
    source("Article7_DecisionMakers/scripts/data_analysis/plots.R",
           local = TRUE, echo = TRUE)
    
    source("Article7_DecisionMakers/scripts/data_analysis/political orientation.R",
           local = TRUE, echo = TRUE)
    
    source("Article7_DecisionMakers/scripts/process_data/process data.R",
           local = TRUE, echo = TRUE)
    
  }),
  silent = FALSE
)

# #Script Ekström et al. (2025), (R part)
try(
  xfun::Rscript_call(function() {
    
    log_file <- "Article12_MakingAPromise/MakingAPromise_log.txt"
    
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
    
    source("Article12_MakingAPromise/MakingAPromise.R", local = TRUE)
    
  }),
  silent = FALSE
)
