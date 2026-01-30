#Master script
library(rmarkdown)
library(here)

root <- here()
#Script Payzan-LeNestour and Woodford (2022)
try(source("Article1_Outlier/Outlier.R"), silent = FALSE)

#Script Payzan-LeNestour et al. (2024)
setwd(root)
source("Article4_Stubborn/run_full_script.R")

# #Script Huber and Huber (2020)
setwd(root)
try(rmarkdown::render("Article5_BadBankers/notebook.Rmd"))

# #Script Snijder et al. (2024)
setwd(root)
source("Article7_DecisionMakers/scripts/data_analysis/models.R")
setwd(root)
source("Article7_DecisionMakers/scripts/data_analysis/partner choice.R")
setwd(root)
source("Article7_DecisionMakers/scripts/data_analysis/plots.R")
setwd(root)
source("Article7_DecisionMakers/scripts/data_analysis/political orientation.R")
setwd(root)
source("Article7_DecisionMakers/scripts/process_data/process data.R")

# #Script Ekström et al. (2025), (R part)
setwd(root)
source("Article12_MakingAPromise/MakingAPromise.R")
