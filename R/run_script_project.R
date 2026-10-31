# Encapsulates execution in an isolated R session via xfun::Rscript_call(),
# ensuring a clean environment set to the project root while redirecting
# output and messages to a log file, with tryCatch() for error handling.
# Accepts either a character path ending in .R or .Rmd (auto source / render)

run_script_project <- function(path, log_file) {
  path_expr <- substitute(path)
  path_raw  <- serialize(path_expr, NULL)

  message("\n=== START: ", log_file, " ===")
  status <- FALSE

  tryCatch({
    xfun::Rscript_call(
      function(path_raw, log_file) {
        path <- unserialize(path_raw)

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

        if (is.character(path) && grepl("\\.Rmd$", path, ignore.case = TRUE)) {
          rmarkdown::render(path, output_format = "html_document", quiet = FALSE)
        } else if (is.character(path)) {
          source(path, local = TRUE)
        } else {
          eval(path, envir = new.env(parent = globalenv()))
        }
      },
      args = list(path_raw = path_raw, log_file = log_file)
    )
    message("=== SUCCESS: ", log_file, " ===")
    status <- TRUE
  }, error = function(e) {
    message("=== ERROR in ", log_file, " ===")
    message(conditionMessage(e))
    cat("ERROR:", conditionMessage(e), "\n", file = log_file, append = TRUE)
  })

  message("=== END: ", log_file, " ===\n")
  invisible(status)
}
