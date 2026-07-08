library(xfun)

run_script_project <- function(script_path, log_file) {
  
  message("\n=== START: ", log_file, " ===")
  
  tryCatch(
    {
      xfun::Rscript_call(
        function(script_path, log_file) {
          
          # Removed options(error = ...) to allow on.exit() to run on failure
          
          library(here)
          setwd(here::here())
          
          message("DEBUG: Child process WD = ", here::here())
          
          dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
          
          con <- file(log_file, open = "wt")
          sink(con)
          sink(con, type = "message")
          
          on.exit({
            sink(type = "message")
            sink()
            close(con)
          }, add = TRUE)
          
          source(script_path, local = new.env(parent = globalenv()))
          
        },
        args = list(script_path = script_path, log_file = log_file)
      )
      message("=== SUCCESS: ", log_file, " ===")
    },
    error = function(e) {
      message("=== ERROR in ", log_file, " ===")
      message(conditionMessage(e))
      cat("ERROR:", conditionMessage(e), "\n", file = log_file, append = TRUE)
    }
  )
  
  message("=== END: ", log_file, " ===\n")
  invisible(NULL)
}