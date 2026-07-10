library(xfun)

run_script_project <- function(expr, log_file) {
  
  expr <- substitute(expr)
  message("\nSTART: ", log_file)
  
  try(
    xfun::Rscript_call(
      function(expr, log_file) {
        
        options(error = quote(quit(status = 1)))
        
        library(here)
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
        
        eval(expr, envir = new.env(parent = globalenv()))
        
      },
      args = list(expr = expr, log_file = log_file)
    ),
    silent = FALSE
  )
  
  message("END: ", log_file, "\n")
}