# Encapsulates execution in an isolated R session via xfun::Rscript_call(),
# ensuring a clean environment set to the project root while redirecting
# output and messages to a log file, with tryCatch() for error handling.
#
# Accepts either a character path ending in .R or .Rmd (auto source / render)

library(xfun)

run_script_project <- function(path, log_file) {

  # Capture the path without evaluating it yet
  path <- substitute(path)

  # Preserve the path as data when passing it to Rscript_call()
  path_raw <- serialize(path, NULL)

  message("\n=== START: ", log_file, " ===")

  status <- FALSE

  tryCatch(
    {
      xfun::Rscript_call(
        function(path_raw, log_file) {

          # Restore the original path without evaluating it
          path <- unserialize(path_raw)

          library(here)
          setwd(here::here())

          message("DEBUG: Child process WD = ", here::here())

          dir.create(dirname(log_file),
                     recursive = TRUE,
                     showWarnings = FALSE)

          con <- file(log_file, open = "wt")
          sink(con)
          sink(con, type = "message")

          on.exit({
            sink(type = "message")
            sink()
            close(con)
          }, add = TRUE)

          # ----- Automatic detection -----
          # File path provided: decide between render() and source()
          if (is.character(path)) {

            if (grepl("\\.Rmd$", path, ignore.case = TRUE)) {

              # .Rmd file -> render
              rmarkdown::render(
                input = path,
                output_format = "html_document",
                quiet = FALSE
              )

            } else {

              # .R file -> source
              source(path, local = TRUE)

            }

          } else {

            # Full block
            eval(path, envir = new.env(parent = globalenv()))

          }
        },
        args = list(path_raw = path_raw, log_file = log_file)
      )
      message("=== SUCCESS: ", log_file, " ===")
      status <- TRUE
    },
    error = function(e) {
      message("=== ERROR in ", log_file, " ===")
      message(conditionMessage(e))
      cat("ERROR:", conditionMessage(e), "\n", file = log_file, append = TRUE)
    }
  )

  message("=== END: ", log_file, " ===\n")
  return(invisible(status))
}
