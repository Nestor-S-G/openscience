#Master script
# R version: 4.5.2
gc()
rm(list = ls())

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
renv::restore()

#Libraries
library(rmarkdown)
library(here)
library(callr)

root <- here()

#Script Payzan-LeNestour and Woodford (2022)
try(
  callr::r(function() {
    library(here)
    setwd(here::here())
    source("Article1_Outlier/Outlier.R")
  }),
  silent = FALSE
)

#Script Payzan-LeNestour et al. (2024)
setwd(root)
