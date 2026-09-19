library(here)
setwd(here::here())

# Stargazer fix
sg_path <- find.package("stargazer")
tmp_tar <- tempfile(fileext = ".tar.gz")
download.file("https://cran.r-project.org/src/contrib/stargazer_5.2.3.tar.gz",
              destfile = tmp_tar, quiet = TRUE)
tmp_dir <- tempdir()
untar(tmp_tar, exdir = tmp_dir)
code <- readLines(file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
l1 <- grep("if (is.na(s))", code, fixed = TRUE)
code[l1] <- gsub("if (is.na(s))", "if (length(s) == 0 || all(is.na(s)))", code[l1], fixed = TRUE)
l2 <- grep('if (s=="")', code, fixed = TRUE)
code[l2] <- gsub('if (s=="")', 'if (length(s) == 0 || all(s == ""))', code[l2], fixed = TRUE)
writeLines(code, file.path(tmp_dir, "stargazer", "R", "stargazer-internal.R"))
install.packages(file.path(tmp_dir, "stargazer"), repos = NULL, type = "source", quiet = TRUE, lib = dirname(sg_path))
cat("stargazer patched for R 4.x\n")

assignInNamespace("tbl_df", tibble::as_tibble, ns = "dplyr")

unlockBinding("ggsave", asNamespace("ggplot2"))
original_ggsave <- ggplot2::ggsave
assign("ggsave", function(filename, ...) {
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  original_ggsave(filename, ...)
}, envir = asNamespace("ggplot2"))
lockBinding("ggsave", asNamespace("ggplot2"))

# Render document
rmarkdown::render(
  input         = "huberBadBankersNo2020/notebook.Rmd",
  output_format = "pdf_document",
  output_file   = "Huber2020_reproduced.pdf",
  clean         = FALSE,
  envir         = globalenv(),
  quiet         = FALSE
)