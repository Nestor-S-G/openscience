# Encapsulates execution in an isolated R session via xfun::Rscript_call(),
# ensuring a clean environment set to the project root while redirecting
# output and messages to a log file, with tryCatch() for error handling.

library(xfun)

run_script_project <- function(expr, log_file) {

  # Capture the expression without evaluating it yet
  expr <- substitute(expr)

  message("\n=== START: ", log_file, " ===")

  status <- FALSE

  tryCatch(
    {
      xfun::Rscript_call(
        function(expr, log_file) {

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

          # Evaluate the expression in a clean environment
          eval(expr, envir = new.env(parent = globalenv()))

        },
        args = list(expr = expr, log_file = log_file)
      )
      message("=== SUCCESS: ", log_file, " ===")
      status <- TRUE
    },
    error = function(e) {
      message("=== ERROR in ", log_file, " ===")
      message(conditionMessage(e))
      # Also write the error to the log file
      cat("ERROR:", conditionMessage(e), "\n", file = log_file, append = TRUE)
      status <- FALSE
    }
  )

  message("=== END: ", log_file, " ===\n")
  return(invisible(status))
}
