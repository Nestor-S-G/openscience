# Pre-execution environment adjustments
assignInNamespace("getActiveDocumentContext",
                  function(...) list(path = file.path(here::here(), "run_full_script.R")),
                  ns = "rstudioapi")

local({
  orig <- get("effectsize", envir = asNamespace("effectsize"))
  assignInNamespace("effectsize", function(x, ...) {
    tryCatch(orig(x, ...), error = function(e) {
      message("effectsize error (skipped): ", conditionMessage(e))
      invisible(NULL)
    })
  }, ns = "effectsize")
})

# Run the target file
source("payzan-lenestourStubbornDesignNeurobiological/Reproducibility/run_full_script.R", local = TRUE)