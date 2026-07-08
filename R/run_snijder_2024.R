library(here)
setwd(here::here())

# Sequential execution of data analysis files
source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/models.R", local = TRUE)
source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/partner choice.R", local = TRUE)
source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/plots.R", local = TRUE)
source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/political orientation.R", local = TRUE)
source("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/process data.R", local = TRUE)