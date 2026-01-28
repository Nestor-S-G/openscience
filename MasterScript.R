#Master script
library(rmarkdown)
library(here)

root <- here()

#Script Article 1
try(source("Article1_Outlier/Outlier.R"), silent = TRUE)

#Script Article 4
setwd(root)
source("Article4_Stubborn/run_full_script.R")

# #Script Article 5
setwd(root)
rmarkdown::render("Article5_BadBankers/notebook.Rmd")

# #Script Article 7
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

# #Script Article 12 (R part)
setwd(root)
source("Article12_MakingAPromise/MakingAPromise.R")
