library(xfun)

run_script_project <- function(expr, log_file) {
  
  expr <- substitute(expr)
  message("\n=== START: ", log_file, " ===")
  
  tryCatch(
    {
      xfun::Rscript_call(
        function(expr, log_file) {
          
          options(error = quote(quit(status = 1)))
          
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
          
          eval(expr, envir = new.env(parent = globalenv()))
          
        },
        args = list(expr = expr, log_file = log_file)
      )
      message("=== SUCCESS: ", log_file, " ===")
    },
    error = function(e) {
      message("=== ERROR in ", log_file, " ===")
      message(conditionMessage(e))
      # Try to log the error even if Rscript_call failed
      cat("ERROR:", conditionMessage(e), "\n", file = log_file, append = TRUE)
    }
  )
  
  message("=== END: ", log_file, " ===\n")
  invisible(NULL)
}