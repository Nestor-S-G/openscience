# =============================================================================
# run_project_script.R
# Reusable function to execute reproducibility scripts with logging
# =============================================================================

library(xfun)

#' Execute an R script with output logging and error handling
#'
#' This function runs an R script in a controlled environment,
#' captures all console output (including messages and errors) into a log file,
#' and returns whether the execution was successful.
#'
#' @param script_path Character. Full or relative path to the .R script to execute.
#' @param log_file Character. Optional. Path to the log file. 
#'        If NULL, it will be automatically generated from the script name.
#' @param echo Logical. Whether to also print output to the console (default TRUE).
#'
#' @return Logical. TRUE if the script executed without errors, FALSE otherwise.
#' Execute an R script with output logging
run_script_project <- function(script_path, 
                               log_file = NULL, 
                               echo = TRUE,
                               base_dir = NULL) {   # <-- NUEVO PARÁMETRO
  
  if (!file.exists(script_path)) {
    stop("Script not found: ", script_path, call. = FALSE)
  }
  
  if (is.null(log_file)) {
    script_dir <- dirname(script_path)
    script_name <- tools::file_path_sans_ext(basename(script_path))
    log_file <- file.path(script_dir, paste0(script_name, "_log.txt"))
  }
  
  dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
  
  message("START: ", basename(script_path), " → Log: ", basename(log_file))
  
  success <- tryCatch({
    
    xfun::Rscript_call(
      function(script_path, log_file, echo, base_dir) {
        
        # === NUEVA LÓGICA DE PATH ===
        if (!is.null(base_dir)) {
          script_path_for_env <- base_dir
        } else if (!is.null(sys.frame(1)$ofile)) {
          script_path_for_env <- dirname(sys.frame(1)$ofile)
        } else {
          script_path_for_env <- dirname(script_path)
        }
        
        assign("script_path", script_path_for_env, envir = .GlobalEnv)
        cat("Script base path set to:", script_path_for_env, "\n")
        
        con <- file(log_file, open = "wt")
        sink(con)
        sink(con, type = "message")
        
        on.exit({
          sink(type = "message")
          sink()
          close(con)
        }, add = TRUE)
        
        source(script_path, local = FALSE, echo = echo)
        
      },
      args = list(script_path = script_path, 
                  log_file = log_file, 
                  echo = echo,
                  base_dir = base_dir)
    )
    
    TRUE
    
  }, error = function(e) {
    message("ERROR executing ", basename(script_path), ": ", conditionMessage(e))
    FALSE
  })
  
  if (success) {
    message("END: ", basename(script_path), " - SUCCESS\n")
  } else {
    message("END: ", basename(script_path), " - FAILED\n")
  }
  
  return(invisible(success))
}