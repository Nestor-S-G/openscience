run_script_project <- function(expr, log_file) {
  
  expr <- substitute(expr)
  message("\n=== START: ", log_file, " ===")
  
  # Create log directory
  dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
  
  con <- file(log_file, open = "wt")
  sink(con)
  sink(con, type = "message")
  
  on.exit({
    sink(type = "message")
    sink()
    close(con)
  }, add = TRUE)
  
  tryCatch({
    message("DEBUG: Starting execution in main process")
    message("DEBUG: Working directory = ", here::here())
    
    # Execute the paper's code
    eval(expr, envir = new.env(parent = globalenv()))
    
    message("=== SUCCESS: ", log_file, " ===")
    
  }, error = function(e) {
    message("=== ERROR in ", log_file, " ===")
    message("Error message: ", conditionMessage(e))
    print(e)
    message("Call stack:")
    print(sys.calls())
    message("=== END OF ERROR LOG ===")
  }, warning = function(w) {
    message("WARNING: ", conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  
  message("=== END: ", log_file, " ===\n")
  
  # Always return invisible so MasterScript continues
  invisible(NULL)
}