# Runs a script in an isolated R session (xfun::Rscript_call()), redirecting
# output and messages to a log file, with tryCatch() for error handling.
# Assumes the working directory is the project root (as set up in MasterScript.R).
# `path` accepts a character path to .R (sourced) / .Rmd (rendered), or a code block { }.
# Returns TRUE on success and FALSE on error (never NULL, since the master stores it in a list).

run_script_project <- function(path, log_file) {
  path_raw <- serialize(substitute(path), NULL)

  message("\n=== START: ", log_file, " ===")

  status <- tryCatch({
    xfun::Rscript_call(
      function(path_raw, log_file) {
        path <- unserialize(path_raw)

        con <- file(log_file, open = "wt")
        sink(con)
        sink(con, type = "message")
        on.exit({
          sink(type = "message")
          sink()
          close(con)
        })

        if (is.character(path) && grepl("\\.Rmd$", path, ignore.case = TRUE)) {
          rmarkdown::render(path, output_format = "html_document")
        } else if (is.character(path)) {
          source(path, local = TRUE)
        } else {
          eval(path, envir = new.env(parent = globalenv()))
        }
      },
      args = list(path_raw = path_raw, log_file = log_file)
    )
    message("=== SUCCESS: ", log_file, " ===")
    TRUE
  }, error = function(e) {
    message("=== ERROR in ", log_file, " ===\n", conditionMessage(e))
    FALSE
  })

  message("=== END: ", log_file, " ===\n")
  invisible(status)
}
