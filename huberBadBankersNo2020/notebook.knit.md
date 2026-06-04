---
title: Data and Analyes for 'Bad bankers no more? Truth-telling and (dis)honesty in
  the finance industry'
author: "Christoph Huber, Juergen Huber"
output:
  html_notebook:
    df_print: tibble
    fig_caption: yes
    fig_height: 6
    fig_width: 8
    theme: lumen
    toc: yes
    toc_depth: 2
    toc_float: yes
editor_options: 
  markdown: 
    wrap: 72
---



# Intro

This file contains R-code to replicate all analyses, tables, and figures
in '*Bad bankers no more? Truth-telling and (dis)honesty in the finance
industry*'.

The experiments were run between November 2018 and January 2020 with
oTree by Chen et al. (2016). All analyses were conducted in R.

Required R-packages:


``` r
library(plyr)
library(tidyverse)
library(readxl)
library(wesanderson)
library(ggthemes)
library(kableExtra)
library(stargazer)
library(lfe)
library(viridis)
library(car)
library(Rmisc)
library(MASS, exclude = "select")
```

First, we import, tidy, reshape, and merge the raw data files from the
experiment (see below).\
**To skip this step**, load the following `.RData`-files and go to
section *Analysis*:


``` r
load("_norms_before.RData")
load("_norms_stud.RData")
load("_norms_studprof.RData")
load("_tt_before.RData")
load("_tt_pf.RData")
load("_tt_stud.RData")
load("_tt.RData")
load("_norms.RData")
load("_reshaped.RData")
load("_reshaped_norms.RData")
load("_merge.RData")
```

# Data preparation

## Import and tidy data

The following commands import the raw experiment output from folder
`_raw` as an `.xlsx`-file into R, converts it into a tibble, and tidies
and organises all relevant variables.

### Import and tidy data from STUD


``` r
csv <- read_xlsx("_raw/data_students1/all_apps_wide_2018-12-14.xlsx") 
csv1 <- read.csv("_raw/data_students2fin/all_apps_wide_2020-01-17.csv")
csv2 <- read.csv("_raw/data_students2neu/all_apps_wide_2020-01-17.csv")
csv3 <- read.csv("_raw/data_students2abs/all_apps_wide_2020-01-17.csv")

data <- tbl_df(csv)
data <- data %>% rbind.fill(csv1, csv2, csv3)

tt_stud <- data %>%
  filter((session.code == "6vi3dw2b"|session.code == "9auk5aea"|session.code=="7q355nra"|session.code == "s1pa9lws"|session.code == "9d565pyp"|session.code == "o75chhp9"), participant._index_in_pages>=11)

tt_stud <- tt_stud %>%
  dplyr::rename(session = session.code,
         context = tt.1.player.context,
         treatment = tt.1.player.treatment,
         subject = participant.code,
         choice1 = tt.1.player.choice_1,
         choice2 = tt.1.player.choice_2,
         choice3 = tt.1.player.choice_3,
         choice4 = tt.1.player.choice_4,
         choice5 = tt.1.player.choice_5,
         belief1 = tt.1.player.belief_1,
         belief2 = tt.1.player.belief_2,
         belief3 = tt.1.player.belief_3,
         belief4 = tt.1.player.belief_4,
         belief5 = tt.1.player.belief_5,
         order = tt.1.player.order,
         severity = tt.1.player.severity,
         reputation = tt.1.player.reputation,         
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,         
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment,
         payoff = participant.payoff) %>%
  mutate(tt = 1,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,
         lies = choice1 + choice2 + choice3 + choice4 + choice5,
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
         ) %>%  
  dplyr::select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt."),
         -starts_with("tt_norms."),
         -starts_with("bt."),
         -starts_with("wordscra.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

norms_stud <- data %>%
  filter((session.code == "f7hlbgua"|session.code == "r8k3mqov"|session.code=="23zy7355")
         & participant._index_in_pages==27)

norms_stud <- norms_stud %>%
  dplyr::rename(session = session.code,
         context = tt_norms.1.player.context,
         subject = participant.code,
         norms_true1 = tt_norms.1.player.norm_true,
         norms_true2 = tt_norms.2.player.norm_true,
         norms_true3 = tt_norms.3.player.norm_true,
         norms_true4 = tt_norms.4.player.norm_true,
         norms_true5 = tt_norms.5.player.norm_true,
         norms_false1 = tt_norms.1.player.norm_false,
         norms_false2 = tt_norms.2.player.norm_false,
         norms_false3 = tt_norms.3.player.norm_false,
         norms_false4 = tt_norms.4.player.norm_false,
         norms_false5 = tt_norms.5.player.norm_false,
         belief1 = tt_norms.5.player.belief_1,
         belief2 = tt_norms.5.player.belief_2,
         belief3 = tt_norms.5.player.belief_3,
         belief4 = tt_norms.5.player.belief_4,
         belief5 = tt_norms.5.player.belief_5,
         order = tt_norms.1.player.order,
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,         
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment) %>%
  mutate(tt = 0,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,       
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
         ) %>%
  dplyr::select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt_norms."),
         -starts_with("tt."),
         -starts_with("bt."),
         -starts_with("wordscra.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

norms_stud <- norms_stud %>%
  mutate(norms_false1 = (norms_false1-3.5) / 2.5,
         norms_false2 = (norms_false2-3.5) / 2.5,
         norms_false3 = (norms_false3-3.5) / 2.5,
         norms_false4 = (norms_false4-3.5) / 2.5,
         norms_false5 = (norms_false5-3.5) / 2.5,
         norms_true1 = (norms_true1-3.5) / 2.5,
         norms_true2 = (norms_true2-3.5) / 2.5,
         norms_true3 = (norms_true3-3.5) / 2.5,
         norms_true4 = (norms_true4-3.5) / 2.5,
         norms_true5 = (norms_true5-3.5) / 2.5,
         norms_false = (norms_false1 + norms_false2 + norms_false3 + norms_false4)/4,
         norms_true = (norms_true1 + norms_true2 + norms_true3 + norms_true4)/4)

save(tt_stud, file="_tt_stud.RData")
save(norms_stud, file="_norms_stud.RData")
```

### Import and tidy data from PROF (before.world)


``` r
csv <- read.csv("_raw/data_before/all_apps_wide_2019-02-27.csv")
data <- tbl_df(csv)

tt_before <- data %>%
  filter((session.code == "sl4o33w2") 
         & participant._index_in_pages==12)

tt_before <- tt_before %>%
  dplyr::rename(session = session.code,
         context = tt.1.player.context,
         subject = participant.code,
         choice1 = tt.1.player.choice_1,
         choice2 = tt.1.player.choice_2,
         choice3 = tt.1.player.choice_3,
         choice4 = tt.1.player.choice_4,
         choice5 = tt.1.player.choice_5,
         belief1 = tt.1.player.belief_1,
         belief2 = tt.1.player.belief_2,
         belief3 = tt.1.player.belief_3,
         belief4 = tt.1.player.belief_4,
         belief5 = tt.1.player.belief_5,
         order = tt.1.player.order,
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment,
         finnews = postexp.1.player.finnews,
         payoff = participant.payoff) %>%
  mutate(tt = 1,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,
         lies = choice1 + choice2 + choice3 + choice4 + choice5,
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
  ) %>%  
  dplyr::select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt."),
         -starts_with("tt_norms."),
         -starts_with("bt."),
         -starts_with("wordscra."),
         -starts_with("redirect.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

norms_before <- data %>%
  filter((session.code == "jzmo442c")
         & participant._index_in_pages==28)

norms_before <- norms_before %>%
  dplyr::rename(session = session.code,
         context = tt_norms.1.player.context,
         subject = participant.code,
         norms_true1 = tt_norms.1.player.norm_true,
         norms_true2 = tt_norms.2.player.norm_true,
         norms_true3 = tt_norms.3.player.norm_true,
         norms_true4 = tt_norms.4.player.norm_true,
         norms_true5 = tt_norms.5.player.norm_true,
         norms_false1 = tt_norms.1.player.norm_false,
         norms_false2 = tt_norms.2.player.norm_false,
         norms_false3 = tt_norms.3.player.norm_false,
         norms_false4 = tt_norms.4.player.norm_false,
         norms_false5 = tt_norms.5.player.norm_false,
         belief1 = tt_norms.5.player.belief_1,
         belief2 = tt_norms.5.player.belief_2,
         belief3 = tt_norms.5.player.belief_3,
         belief4 = tt_norms.5.player.belief_4,
         belief5 = tt_norms.5.player.belief_5,
         order = tt_norms.1.player.order,
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,         
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment,
         finnews = postexp.1.player.finnews) %>%
  mutate(tt = 0,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,       
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
  ) %>%
  dplyr::select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt_norms."),
         -starts_with("tt."),
         -starts_with("bt."),
         -starts_with("wordscra."),
         -starts_with("redirect.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

norms_before <- norms_before %>%
  mutate(norms_false1 = (norms_false1-3.5) / 2.5,
         norms_false2 = (norms_false2-3.5) / 2.5,
         norms_false3 = (norms_false3-3.5) / 2.5,
         norms_false4 = (norms_false4-3.5) / 2.5,
         norms_false5 = (norms_false5-3.5) / 2.5,
         norms_true1 = (norms_true1-3.5) / 2.5,
         norms_true2 = (norms_true2-3.5) / 2.5,
         norms_true3 = (norms_true3-3.5) / 2.5,
         norms_true4 = (norms_true4-3.5) / 2.5,
         norms_true5 = (norms_true5-3.5) / 2.5,
         norms_false = (norms_false1 + norms_false2 + norms_false3 + norms_false4)/4,
         norms_true = (norms_true1 + norms_true2 + norms_true3 + norms_true4)/4)

save(tt_before, file="_tt_before.RData")
save(norms_before, file="_norms_before.RData")
```

### Import and tidy data from STUDPROF.


``` r
csv <- read_xlsx("_raw/data_studprof/all_apps_wide_2019-04-15.xlsx") 

data <- tbl_df(csv)

norms_studprof <- data %>%
  filter((session.code == "7v1jo4vk")
         & participant._index_in_pages==27)

norms_studprof <- norms_studprof %>%
  dplyr::rename(session = session.code,
         context = tt_norms.1.player.context,
         subject = participant.code,
         norms_true1 = tt_norms.1.player.norm_true,
         norms_true2 = tt_norms.2.player.norm_true,
         norms_true3 = tt_norms.3.player.norm_true,
         norms_true4 = tt_norms.4.player.norm_true,
         norms_true5 = tt_norms.5.player.norm_true,
         norms_false1 = tt_norms.1.player.norm_false,
         norms_false2 = tt_norms.2.player.norm_false,
         norms_false3 = tt_norms.3.player.norm_false,
         norms_false4 = tt_norms.4.player.norm_false,
         norms_false5 = tt_norms.5.player.norm_false,
         belief1 = tt_norms.5.player.belief_1,
         belief2 = tt_norms.5.player.belief_2,
         belief3 = tt_norms.5.player.belief_3,
         belief4 = tt_norms.5.player.belief_4,
         belief5 = tt_norms.5.player.belief_5,
         order = tt_norms.1.player.order,
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,         
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment) %>%
  mutate(tt = 0,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,       
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
         ) %>%
  dplyr::select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt_norms."),
         -starts_with("tt."),
         -starts_with("bt."),
         -starts_with("wordscra.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

norms_studprof <- norms_studprof %>%
  mutate(norms_false1 = (norms_false1-3.5) / 2.5,
         norms_false2 = (norms_false2-3.5) / 2.5,
         norms_false3 = (norms_false3-3.5) / 2.5,
         norms_false4 = (norms_false4-3.5) / 2.5,
         norms_false5 = (norms_false5-3.5) / 2.5,
         norms_true1 = (norms_true1-3.5) / 2.5,
         norms_true2 = (norms_true2-3.5) / 2.5,
         norms_true3 = (norms_true3-3.5) / 2.5,
         norms_true4 = (norms_true4-3.5) / 2.5,
         norms_true5 = (norms_true5-3.5) / 2.5,
         norms_false = (norms_false1 + norms_false2 + norms_false3 + norms_false4)/4,
         norms_true = (norms_true1 + norms_true2 + norms_true3 + norms_true4)/4)

save(norms_studprof, file="_norms_studprof.RData")
```

### Import and tidy data from PROLIFIC


``` r
csv <- read.csv("_raw/data_prolific/all_apps_wide_2020-01-08.csv")
csv1 <- read.csv("_raw/data_prolific/all_apps_wide_2020-01-14.csv")
csv2 <- read.csv("_raw/data_prolific/all_apps_wide_2020-01-17.csv")

data <- rbind(csv, csv1, csv2) %>% tbl_df()

exp <- read.csv("_raw/data_prolific/prolific_export_5e1478086e8aaba68ddcfa31.csv") %>% 
  dplyr::rename(participant.label = participant_id,
         age.prolific = age)

data <- left_join(data, exp,
                  by=c("participant.label"))

tt_pf <- data %>%
  filter((session.code == "cfs9uxep"|session.code == "t3qqecpo"|session.code == "b7rrvg7s") 
         & participant._index_in_pages==12)

tt_pf <- tt_pf %>%
  dplyr::rename(session = session.code,
         context = tt.1.player.context,
         treatment = tt.1.player.treatment,
         subject = participant.code,
         choice1 = tt.1.player.choice_1,
         choice2 = tt.1.player.choice_2,
         choice3 = tt.1.player.choice_3,
         choice4 = tt.1.player.choice_4,
         choice5 = tt.1.player.choice_5,
         belief1 = tt.1.player.belief_1,
         belief2 = tt.1.player.belief_2,
         belief3 = tt.1.player.belief_3,
         belief4 = tt.1.player.belief_4,
         belief5 = tt.1.player.belief_5,
         order = tt.1.player.order,
         severity = tt.1.player.severity,
         reputation = tt.1.player.reputation,
         pref1_1 = postexp.1.player.pref1_1,
         pref1_2 = postexp.1.player.pref1_2,
         pref1_3 = postexp.1.player.pref1_3,
         pref1_4 = postexp.1.player.pref1_4,
         pref2_1 = postexp.1.player.pref2_1,
         pref2_2 = postexp.1.player.pref2_2,
         pref2_3 = postexp.1.player.pref2_3,
         risk = postexp.1.player.risk_aversion1,
         age = postexp.1.player.age,
         female = postexp.1.player.female,
         education = postexp.1.player.education,
         job = postexp.1.player.jobfunction,
         investment = postexp.1.player.investment,
         whichinvestment = postexp.1.player.whichinvestment,
         finnews = postexp.1.player.finnews,
         payoff = participant.payoff) %>%
  mutate(tt = 1,
         word1 = paste0(wordscra.1.player.word1_1,
                        wordscra.1.player.word1_2,
                        wordscra.1.player.word1_3,
                        wordscra.1.player.word1_4,
                        wordscra.1.player.word1_5),
         word2 = paste0(wordscra.1.player.word2_1,
                        wordscra.1.player.word2_2,
                        wordscra.1.player.word2_3),
         word3 = paste0(wordscra.1.player.word3_1,
                        wordscra.1.player.word3_2,
                        wordscra.1.player.word3_3,
                        wordscra.1.player.word3_4,
                        wordscra.1.player.word3_5,
                        wordscra.1.player.word3_6),
         word4 = paste0(wordscra.1.player.word4_1,
                        wordscra.1.player.word4_2,
                        wordscra.1.player.word4_3,
                        wordscra.1.player.word4_4,
                        wordscra.1.player.word4_5),
         word5 = paste0(wordscra.1.player.word5_1,
                        wordscra.1.player.word5_2,
                        wordscra.1.player.word5_3,
                        wordscra.1.player.word5_4,
                        wordscra.1.player.word5_5),
         word6 = paste0(wordscra.1.player.word6_1,
                        wordscra.1.player.word6_2,
                        wordscra.1.player.word6_3,
                        wordscra.1.player.word6_4),
         word1f = ifelse(word1 == tools::toTitleCase(tolower("stock")), 1, 0),
         word3f = ifelse(word3 == tools::toTitleCase(tolower("broker")), 1, 0),
         word4f = ifelse(word4 == tools::toTitleCase(tolower("money")), 1, 0),
         word6f = ifelse(word6 == tools::toTitleCase(tolower("bond")), 1, 0),
         wordsf = word1f + word3f + word4f + word6f,
         lies = choice1 + choice2 + choice3 + choice4 + choice5,
         beliefs = belief1/100 + belief2/100 + belief3/100 + belief4/100 + belief5/100
  ) %>%  
  select(-starts_with("participant."),
         -starts_with("session."),
         -starts_with("postexp"),
         -starts_with("tt."),
         -starts_with("tt_norms."),
         -starts_with("bt."),
         -starts_with("wordscra."),
         -starts_with("redirect.")) %>%
  arrange(session, context, subject) %>%
  group_by(context)

save(tt_pf, file="_tt_pf.RData")
```

## Reshape and merge

### Reshape data


``` r
tt_stud_reshaped <- tt_stud %>%
  gather(cost, choice, choice1:choice5, belief1:belief5)
tt_stud_reshaped <- tt_stud_reshaped %>%
  extract(cost, c("question", "cost"), "(choice|belief)(.)")%>% 
  mutate(
    treatment = ifelse(context == "financial", "sh_sev_fin",
                       ifelse(context == "neutral", "su_ha_neu",
                              "su_ha_abs")))

tt_before_reshaped <- tt_before %>%
  gather(cost, choice, choice1:choice5, belief1:belief5)
tt_before_reshaped <- tt_before_reshaped %>%
  extract(cost, c("question", "cost"), "(choice|belief)(.)")%>% 
  mutate(
    treatment = ifelse(context == "financial", "sh_sev_fin",
                       ifelse(context == "neutral", "su_ha_neu",
                              "su_ha_abs")))

tt_pf_reshaped <- tt_pf %>%
  gather(cost, choice, choice1:choice5, belief1:belief5)
tt_pf_reshaped <- tt_pf_reshaped %>%
  extract(cost, c("question", "cost"), "(choice|belief)(.)") %>% 
  mutate(
    treatment = ifelse(is.na(treatment),
                       ifelse(context == "financial", "sh_sev_fin",
                              ifelse(context == "neutral", "su_ha_neu",
                                     ifelse(context == "abstract", "su_ha_abs", context))),
                       as.character(treatment))
    )
```

### Merge STUD and PROF data


``` r
tt_before$prof <- rep(1, nrow(tt_before))
norms_before$prof <- rep(1, nrow(norms_before))
tt_stud$prof <- rep(0, nrow(tt_stud))
norms_stud$prof <- rep(0, nrow(norms_stud))
norms_studprof$prof <- rep(2, nrow(norms_studprof))
tt_pf$prof <- rep(3, nrow(tt_pf))

tt_before$prof1 <- rep(1, nrow(tt_before))
norms_before$prof1 <- rep(1, nrow(norms_before))
tt_stud$prof1 <- rep(0, nrow(tt_stud))
norms_stud$prof1 <- rep(0, nrow(norms_stud))
norms_studprof$prof1 <- rep(0, nrow(norms_studprof))
tt_pf$prof1 <- rep(1, nrow(tt_pf))

tt_stud <- tt_stud %>% 
  mutate(
    treatment = ifelse(is.na(treatment),
                       ifelse(context == "financial", "sh_sev_fin",
                              ifelse(context == "neutral", "su_ha_neu",
                                     ifelse(context == "abstract", "su_ha_abs",
context))),
                       as.character(treatment))
    )
tt_stud$treatment <- factor(tt_stud$treatment)


tt <- rbind(tt_before, tt_stud, tt_pf)
norms <- rbind(norms_before, norms_stud, norms_studprof)

tt <- tt %>% 
  mutate(
    treatment = ifelse(is.na(treatment),
                       ifelse(context == "financial", "sh_sev_fin",
                              ifelse(context == "neutral", "su_ha_neu",
                                     ifelse(context == "abstract", "su_ha_abs", context))),
                       as.character(treatment))
    )
tt$treatment <- factor(tt$treatment)

norms <- norms %>% 
  mutate(
    treatment = ifelse(context == "financial", "sh_sev_fin",
                       ifelse(context == "neutral", "su_ha_neu",
                              ifelse(context == "abstract", "su_ha_abs", context))),
    treatment)
norms$treatment <- factor(norms$treatment)


tt <- tt %>% 
  mutate(
    job1 = ifelse(job == 0, "Portfolio Manager",
                           ifelse(job == 1, "Research Analyst",
                                  ifelse(job == 2, "Consultant",
                                         ifelse(job == 3, "Financial Advisor",
                                                ifelse(job == 4, "Chief-Level Executive",
                                                       ifelse(job == 5, "Trader",
                                                              ifelse(job == 6, "Fund Manager",
                                                                     ifelse(job == 7, "Investment Managent",
                                                                            "Other"))))))))   
  )

norms <- norms %>% 
  mutate(
    job1 = ifelse(job == 0, "Portfolio Manager",
                           ifelse(job == 1, "Research Analyst",
                                  ifelse(job == 2, "Consultant",
                                         ifelse(job == 3, "Financial Advisor",
                                                ifelse(job == 4, "Chief-Level Executive",
                                                       ifelse(job == 5, "Trader",
                                                              ifelse(job == 6, "Fund Manager",
                                                                     ifelse(job == 7, "Investment Managent",
                                                                            "Other"))))))))   
  )


save(tt, file = "_tt.RData")
save(norms, file = "_norms.RData")
```

### Reshape pooled tt and norms

TT


``` r
reshaped <- tt %>%
  gather(cost, choice, choice1:choice5, belief1:belief5)
reshaped <- reshaped %>%
  extract(cost, c("question", "cost"), "(choice|belief)(.)")
reshaped <- reshaped %>%
  spread(question, choice)

reshaped$belief <- reshaped$belief/100
reshaped$cost <- as.numeric(reshaped$cost) * (-1) + 5

save(reshaped, file = "_reshaped.RData")
```

Norms


``` r
reshaped_norms <- norms %>%
  select(-norms_false, -norms_true) %>%
  gather(cost, choice, norms_true1:norms_false5, norms_false1:norms_false5, belief1:belief5)
reshaped_norms <- reshaped_norms %>%
  extract(cost, c("question", "cost"), "(norms_false|norms_true|belief)(.)")
reshaped_norms <- reshaped_norms %>%
  spread(question, choice) %>%
  mutate(norms = (norms_true + norms_false)/2)

reshaped_norms$belief <- reshaped_norms$belief/100
reshaped_norms$cost <- as.numeric(reshaped_norms$cost) * (-1) + 5

save(reshaped_norms, file = "_reshaped_norms.RData")
```

### Merge


``` r
reshaped$treatment1 <- factor(reshaped$treatment,
                              levels = c('sh_sev_fin',
                                         'sh_ha_fin',
                                         'su_ha_neu',
                                         'su_sev_fin',
                                         'su_ha_abs',
                                         'su_ha_fin'))

reshaped_norms$treatment1 <- factor(reshaped_norms$treatment,
                              levels = c('sh_sev_fin',
                                         'sh_ha_fin',
                                         'su_ha_neu',
                                         'su_sev_fin',
                                         'su_ha_abs',
                                         'su_ha_fin'))

merge <- left_join(reshaped,
                   reshaped_norms %>%
                     group_by(prof, treatment1, cost) %>%
                     summarise(norms_false = mean(norms_false),
                               norms_true = mean(norms_true),
                               norms_belief = mean(belief),
                               prof1 = mean(prof1)) %>% 
                     na.omit(),
                   by=c("treatment1", "cost"),
                   suffix = c(".tt", ".norms")) %>% 
  filter(!is.na(prof.norms))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof, treatment1, and cost.
## i Output is grouped by prof and treatment1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof, treatment1, cost))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## Warning in left_join(reshaped, reshaped_norms %>% group_by(prof, treatment1, : Detected an unexpected many-to-many relationship between `x` and `y`.
## i Row 1 of `x` matches multiple rows in `y`.
## i Row 15 of `y` matches multiple rows in `x`.
## i If a many-to-many relationship is expected, set `relationship =
##   "many-to-many"` to silence this warning.
```

``` r
merge <- merge %>% mutate(norm = ifelse(choice==0, norms_true, norms_false))

save(merge, file = "_merge.RData")
```

# Analysis

## Table 2

Proportion of dishonest reports for financial professionals and students
across treatments


``` r
tt %>% 
  group_by(prof1, treatment) %>% 
  summarise(Pct = 1 - mean(lies, na.rm=TRUE)/5,
            sd = sd(lies/5, na.rm=TRUE),
            n = n()) %>%
  pivot_wider(names_from = prof1,
              values_from = c(Pct, sd, n)) %>%
  select(treatment,
         Pct_1, sd_1, n_1,
         Pct_0, sd_0, n_0)
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof1 and treatment.
## i Output is grouped by prof1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof1, treatment))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## # A tibble: 6 x 7
##   treatment  Pct_1  sd_1   n_1  Pct_0   sd_0   n_0
##   <fct>      <dbl> <dbl> <int>  <dbl>  <dbl> <int>
## 1 sh_sev_fin 0.662 0.350    93  0.323  0.223    57
## 2 su_ha_abs  0.430 0.352    61  0.295  0.234    55
## 3 su_ha_neu  0.6   0.334    69  0.356  0.290    54
## 4 sh_ha_fin  0.630 0.402    67 NA     NA        NA
## 5 su_ha_fin  0.703 0.349    74 NA     NA        NA
## 6 su_sev_fin 0.663 0.359    51 NA     NA        NA
```

Fisher's exact tests for differences between treatments and subject
pools in Table 2


``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs") %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs") %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 0.0007707
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  1.259839 2.584840
## sample estimates:
## odds ratio 
##   1.801363
```

``` r
fisher.test(tt %>%
    filter(treatment == "su_ha_abs") %>% 
    mutate(truths = 5 - lies) %>%
    group_by(prof1, truths) %>%
    summarise(n = n()) %>% 
    pivot_wider(names_from = prof1, values_from = n) %>% 
    select(`0`, `1`) %>% 
    mutate(`0` = ifelse(is.na(`0`), 0, `0`)))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof1 and truths.
## i Output is grouped by prof1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof1, truths))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  tt %>% filter(treatment == "su_ha_abs") %>% mutate(truths = 5 - lies) %>% group_by(prof1, truths) %>% summarise(n = n()) %>% pivot_wider(names_from = prof1, values_from = n) %>% select(`0`, `1`) %>% mutate(`0` = ifelse(is.na(`0`), 0, `0`))
## p-value = 0.01988
## alternative hypothesis: two.sided
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_neu") %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_neu") %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 1.666e-09
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  1.930016 3.832415
## sample estimates:
## odds ratio 
##    2.71397
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "sh_sev_fin") %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "sh_sev_fin") %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.970967 5.708049
## sample estimates:
## odds ratio 
##   4.106707
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs" | treatment == "su_ha_neu", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs" | treatment == "su_ha_neu", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 1.508e-05
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  1.439713 2.757502
## sample estimates:
## odds ratio 
##   1.990223
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_neu" | treatment == "sh_sev_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_neu" | treatment == "sh_sev_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 0.07638
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.5670733 1.0316256
## sample estimates:
## odds ratio 
##  0.7648775
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_neu" | treatment == "sh_ha_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_neu" | treatment == "sh_ha_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 0.4317
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.6392648 1.2152731
## sample estimates:
## odds ratio 
##  0.8816817
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_neu" | treatment == "su_ha_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_neu" | treatment == "su_ha_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 0.004618
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.4597632 0.8756031
## sample estimates:
## odds ratio 
##  0.6350387
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_neu" | treatment == "su_sev_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_neu" | treatment == "su_sev_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 0.1248
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.922487 1.863805
## sample estimates:
## odds ratio 
##    1.30948
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs" | treatment == "sh_sev_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs" | treatment == "sh_sev_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 2.099e-10
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.2819450 0.5223579
## sample estimates:
## odds ratio 
##  0.3842967
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs" | treatment == "sh_ha_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs" | treatment == "sh_ha_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 5.328e-07
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.3181272 0.6152152
## sample estimates:
## odds ratio 
##   0.443027
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs" | treatment == "su_ha_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs" | treatment == "su_ha_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 7.975e-13
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.255993 4.370244
## sample estimates:
## odds ratio 
##   3.133817
```

``` r
fisher.test(t(tt %>%
                filter(treatment == "su_ha_abs" | treatment == "su_sev_fin", 
                     prof1 == 1) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(treatment) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter(treatment == "su_ha_abs" | treatment == "su_sev_fin", prof1 == 1) %>% mutate(truths = 5 - lies) %>% group_by(treatment) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 4.524e-08
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  1.822846 3.741251
## sample estimates:
## odds ratio 
##   2.605537
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_abs" & prof1 == 0) | (treatment == "sh_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.857242 5.819375
## sample estimates:
## odds ratio 
##   4.064949
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_abs" & prof1 == 0) | (treatment == "su_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  3.965084 8.090910
## sample estimates:
## odds ratio 
##   5.643898
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_abs" & prof1 == 0) | (treatment == "su_sev_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  3.208177 6.909541
## sample estimates:
## odds ratio 
##   4.691418
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_neu" & prof1 == 0) | (treatment == "sh_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 2.601e-11
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.179459 4.367056
## sample estimates:
## odds ratio 
##   3.078125
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_neu" & prof1 == 0) | (treatment == "su_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  3.024817 6.070014
## sample estimates:
## odds ratio 
##   4.273418
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "su_ha_neu" & prof1 == 0) | (treatment == "su_sev_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 1.975e-12
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.446300 5.189032
## sample estimates:
## odds ratio 
##    3.55228
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "sh_sev_fin" & prof1 == 0) | (treatment == "sh_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 2.276e-14
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.524411 5.051531
## sample estimates:
## odds ratio 
##   3.561745
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "sh_sev_fin" & prof1 == 0) | (treatment == "su_ha_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value < 2.2e-16
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  3.503829 7.022560
## sample estimates:
## odds ratio 
##   4.945024
```

``` r
fisher.test(t(tt %>%
                filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1)) %>% 
                mutate(truths = 5 - lies) %>%
                group_by(prof1) %>%
                summarise(lies = sum(lies), truths = sum(truths)) %>%
                drop_na() %>%
                ungroup() %>%
                select(lies, truths)))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(tt %>% filter((treatment == "sh_sev_fin" & prof1 == 0) | (treatment == "su_sev_fin" & prof1 == 1)) %>% mutate(truths = 5 - lies) %>% group_by(prof1) %>% summarise(lies = sum(lies), truths = sum(truths)) %>% drop_na() %>% ungroup() %>% select(lies, truths))
## p-value = 2.421e-15
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  2.833528 6.001503
## sample estimates:
## odds ratio 
##   4.110742
```

Wilcoxon rank sum tests for differences between treatments and subject
pools in Table 2


``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_abs" | treatment == "su_ha_neu", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2685, p-value = 0.005688
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_abs" | treatment == "sh_sev_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1843.5, p-value = 0.0001608
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_neu" | treatment == "sh_sev_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2884, p-value = 0.2537
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_abs" | treatment == "su_ha_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 3172, p-value = 2.857e-05
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_neu" | treatment == "su_sev_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1958.5, p-value = 0.2743
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_neu" | treatment == "sh_ha_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2178, p-value = 0.5466
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ treatment,
            data = tt %>% 
              filter(treatment == "su_ha_neu" | treatment == "su_ha_fin", 
                     prof1 == 1)
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2119.5, p-value = 0.06654
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter(treatment == "su_ha_abs")
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 1993, p-value = 0.0743
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter(treatment == "su_ha_neu")
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2634.5, p-value = 5.874e-05
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter(treatment == "sh_sev_fin")
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 4060, p-value = 2.265e-08
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2702, p-value = 6.15e-06
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 3278.5, p-value = 1.314e-09
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_abs" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2195.5, p-value = 3.088e-07
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2498.5, p-value = 0.0002264
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 3054, p-value = 1.457e-07
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "su_ha_neu" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2033.5, p-value = 1.721e-05
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "sh_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2721.5, p-value = 3.108e-05
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "su_ha_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 3333.5, p-value = 4.986e-09
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof1,
            data = tt %>% 
              filter((treatment == "sh_sev_fin" & prof1 == 0) | 
                        (treatment == "su_sev_fin" & prof1 == 1))
            )
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof1
## W = 2230, p-value = 1.066e-06
## alternative hypothesis: true location shift is not equal to 0
```

Treatment differences in STUD


``` r
# Wilcoxon rank sum test: abstract vs. neutral
wilcox.test(lies ~ treatment, data = tt %>% filter(prof1 == 0, treatment != "sh_sev_fin"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1607.5, p-value = 0.4467
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: abstract vs. financial
wilcox.test(lies ~ treatment, data = tt %>% filter(prof1 == 0, treatment != "su_ha_neu"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1474, p-value = 0.5755
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: neutral vs. financial
wilcox.test(lies ~ treatment, data = tt %>% filter(prof1 == 0, treatment != "su_ha_abs"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1569, p-value = 0.8564
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Kruskal-Wallis test
kruskal.test(lies ~ as.factor(treatment), data = tt %>% filter(prof1 == 0))
```

```
## 
## 	Kruskal-Wallis rank sum test
## 
## data:  lies by as.factor(treatment)
## Kruskal-Wallis chi-squared = 0.62287, df = 2, p-value = 0.7324
```

``` r
# Fisher's exact test
test <- tt %>%
  filter(prof1 == 0) %>% 
  mutate(truths = 5 - lies) %>% 
  group_by(treatment) %>% 
  summarise(lies = sum(lies), truths = sum(truths)) %>% 
  drop_na() %>% 
  ungroup() %>% 
  select(lies, truths)
fisher.test(test)
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  test
## p-value = 0.3128
## alternative hypothesis: two.sided
```

``` r
fisher.test(t(test))
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  t(test)
## p-value = 0.3128
## alternative hypothesis: two.sided
```

Treatment differences in STUD


``` r
# Wilcoxon rank sum test: abstract vs. neutral
wilcox.test(lies ~ context, data = tt_stud %>% filter(context != "financial"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by context
## W = 2009, p-value = 0.1185
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: abstract vs. financial
wilcox.test(lies ~ context, data = tt_stud %>% filter(context != "neutral"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by context
## W = 2067, p-value = 0.06041
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: neutral vs. financial
wilcox.test(lies ~ context, data = tt_stud %>% filter(context != "abstract"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  lies by context
## W = 782, p-value = 0.8612
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Kruskal-Wallis test
kruskal.test(lies ~ as.factor(treatment), data = tt_stud)
```

```
## 
## 	Kruskal-Wallis rank sum test
## 
## data:  lies by as.factor(treatment)
## Kruskal-Wallis chi-squared = 0.62287, df = 2, p-value = 0.7324
```

Treatment differences in PROF


``` r
# Wilcoxon rank sum test: abstract vs. neutral
wilcox.test(lies ~ treatment, data = tt %>% 
              filter(prof1==1,
                     treatment == "su_ha_abs" | treatment == "su_ha_neu"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2685, p-value = 0.005688
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: abstract vs. financial
wilcox.test(lies ~ treatment, data = tt %>% 
              filter(prof1==1,
                     treatment == "su_ha_abs" | treatment == "sh_sev_fin"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 1843.5, p-value = 0.0001608
## alternative hypothesis: true location shift is not equal to 0
```

``` r
# Wilcoxon rank sum test: neutral vs. financial
wilcox.test(lies ~ treatment, data = tt %>% 
              filter(prof1==1,
                     treatment == "sh_sev_fin" | treatment == "su_ha_neu"))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by treatment
## W = 2884, p-value = 0.2537
## alternative hypothesis: true location shift is not equal to 0
```

## Table B1

Proportion of dishonest reports per subject pool across treatments


``` r
tt %>% 
  group_by(prof, treatment) %>% 
  summarise(Pct = 1 - mean(lies, na.rm=TRUE)/5,
            sd = sd(lies/5, na.rm=TRUE),
            n = n()) %>%
  pivot_wider(names_from = prof,
              values_from = c(Pct, sd, n)) %>%
  select(treatment,
         Pct_1, sd_1, n_1,
         Pct_3, sd_3, n_3,
         Pct_0, sd_0, n_0)
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof and treatment.
## i Output is grouped by prof.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof, treatment))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## # A tibble: 6 x 10
##   treatment   Pct_1   sd_1   n_1 Pct_3  sd_3   n_3  Pct_0   sd_0   n_0
##   <fct>       <dbl>  <dbl> <int> <dbl> <dbl> <int>  <dbl>  <dbl> <int>
## 1 sh_sev_fin  0.653  0.314    38 0.669 0.376    55  0.323  0.223    57
## 2 su_ha_abs   0.376  0.351    34 0.496 0.348    27  0.295  0.234    55
## 3 su_ha_neu   0.521  0.306    43 0.731 0.344    26  0.356  0.290    54
## 4 sh_ha_fin  NA     NA        NA 0.630 0.402    67 NA     NA        NA
## 5 su_ha_fin  NA     NA        NA 0.703 0.349    74 NA     NA        NA
## 6 su_sev_fin NA     NA        NA 0.663 0.359    51 NA     NA        NA
```

Wilcoxon rank sum tests for differences between subject pools in Table
B1


``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "sh_sev_fin", prof > 0))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 1091.5, p-value = 0.7054
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_abs", prof > 0))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  lies by prof
## W = 556.5, p-value = 0.1486
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_neu", prof > 0))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  lies by prof
## W = 751, p-value = 0.01405
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "sh_sev_fin", prof != 3))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 1696, p-value = 1.795e-06
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_abs", prof != 3))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 1002, p-value = 0.5637
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_neu", prof != 3))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 1531.5, p-value = 0.005865
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "sh_sev_fin", prof != 1))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 2364, p-value = 2.105e-06
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_abs", prof != 1))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 991, p-value = 0.01162
## alternative hypothesis: true location shift is not equal to 0
```

``` r
wilcox.test(lies ~ prof,
            data = tt %>% filter(treatment == "su_ha_neu", prof != 1))
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  lies by prof
## W = 1103, p-value = 2.45e-05
## alternative hypothesis: true location shift is not equal to 0
```

## Table B9

Subject demographics


``` r
demographics_prof0_mean <- tt %>% 
  ungroup() %>% 
  filter(prof == 0,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF0")

demographics_prof0_sd <- tt %>% 
  ungroup() %>% 
  filter(prof == 0,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF0")

demographics_prof1_mean <- tt %>% 
  ungroup() %>% 
  filter(prof == 1) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF1")

demographics_prof1_sd <- tt %>% 
  ungroup() %>% 
  filter(prof == 1) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF1")

demographics_prof3_mean <- tt %>% 
  ungroup() %>% 
  filter(prof == 3,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF3")

demographics_prof3_sd <- tt %>% 
  ungroup() %>% 
  filter(prof == 3,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF3")

demographics_prof0norms_mean <- norms %>% 
  ungroup() %>% 
  filter(prof == 0,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF0norms")

demographics_prof0norms_sd <- norms %>% 
  ungroup() %>% 
  filter(prof == 0,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF0norms")

demographics_prof1norms_mean <- norms %>% 
  ungroup() %>% 
  filter(prof == 1,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF1norms")

demographics_prof1norms_sd <- norms %>% 
  ungroup() %>% 
  filter(prof == 1,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF1norms")

demographics_prof2norms_mean <- norms %>% 
  ungroup() %>% 
  filter(prof == 2,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = mean(risk),
            age = mean(age), 
            female = mean(female), 
            invest = mean(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "Mean PROF2norms")

demographics_prof2norms_sd <- norms %>% 
  ungroup() %>% 
  filter(prof == 2,
         age <= 100) %>% 
  summarise(n = n(), 
            risk = sd(risk),
            age = sd(age), 
            female = sd(female), 
            invest = sd(investment)) %>% 
  pivot_longer(-n, names_to = "Variable", values_to = "SD PROF2norms")

demographics_prof <- demographics_prof1_mean %>% 
  left_join(demographics_prof1_sd) %>% 
  left_join(demographics_prof3_mean, by = c("Variable")) %>% 
  left_join(demographics_prof3_sd, by = c("Variable")) %>%
  left_join(demographics_prof1norms_mean, by = c("Variable")) %>% 
  left_join(demographics_prof1norms_sd, by = c("Variable")) %>%
  select(-starts_with("n"))
```

```
## Joining with `by = join_by(n, Variable)`
```

``` r
demographics_stud <- demographics_prof0_mean %>% 
  left_join(demographics_prof0_sd) %>% 
  left_join(demographics_prof0norms_mean, by = c("Variable")) %>% 
  left_join(demographics_prof0norms_sd, by = c("Variable")) %>%
  left_join(demographics_prof2norms_mean, by = c("Variable")) %>% 
  left_join(demographics_prof2norms_sd, by = c("Variable")) %>%
  select(-starts_with("n"))
```

```
## Joining with `by = join_by(n, Variable)`
```

``` r
demographics_prof %>%
  kable(format = "latex", 
        booktabs = T, 
        caption = "Demographics", 
        digits = 3) %>% 
  kable_styling(latex_options = c("hold_position"),
                full_width = T)
```

\begin{table}[!h]
\centering
\caption{\label{tab:unnamed-chunk-20}Demographics}
\centering
\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X}
\toprule
Variable & Mean PROF1 & SD PROF1 & Mean PROF3 & SD PROF3 & Mean PROF1norms & SD PROF1norms\\
\midrule
risk & 4.713 & 1.241 & 3.930 & 1.444 & 4.622 & 1.386\\
age & 38.400 & 7.809 & 36.378 & 9.482 & 41.578 & 8.214\\
female & 0.087 & 0.283 & 0.512 & 0.507 & 0.067 & 0.252\\
invest & 0.948 & 0.223 & 0.592 & 0.492 & 0.956 & 0.208\\
\bottomrule
\end{tabu}
\end{table}

``` r
demographics_stud %>%
  kable(format = "latex", 
        booktabs = T, 
        caption = "Demographics", 
        digits = 3) %>% 
  kable_styling(latex_options = c("hold_position"),
                full_width = T)
```

\begin{table}[!h]
\centering
\caption{\label{tab:unnamed-chunk-20}Demographics}
\centering
\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X>{\raggedleft}X}
\toprule
Variable & Mean PROF0 & SD PROF0 & Mean PROF0norms & SD PROF0norms & Mean PROF2norms & SD PROF2norms\\
\midrule
risk & 4.067 & 1.397 & 4.386 & 1.333 & 4.059 & 1.495\\
age & 23.594 & 4.629 & 23.171 & 2.919 & 23.426 & 7.097\\
female & 0.582 & 0.495 & 0.571 & 0.527 & 0.603 & 0.493\\
invest & 0.261 & 0.440 & 0.314 & 0.468 & 0.250 & 0.436\\
\bottomrule
\end{tabu}
\end{table}


``` r
tt_before %>% 
  ungroup() %>% 
  group_by(prof, education) %>% 
  summarise(Prop = round(n()/115, 3))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof and education.
## i Output is grouped by prof.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof, education))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## # A tibble: 5 x 3
## # Groups:   prof [1]
##    prof education  Prop
##   <dbl>     <int> <dbl>
## 1     1        -1 0.009
## 2     1         0 0.009
## 3     1         2 0.017
## 4     1         3 0.096
## 5     1         4 0.87
```

``` r
tt_pf %>% 
  ungroup() %>% 
  group_by(prof, education) %>% 
  summarise(Prop = round(n()/300, 3))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof and education.
## i Output is grouped by prof.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof, education))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## # A tibble: 6 x 3
## # Groups:   prof [1]
##    prof education  Prop
##   <dbl>     <int> <dbl>
## 1     3        -1 0.01 
## 2     3         0 0.01 
## 3     3         1 0.017
## 4     3         2 0.077
## 5     3         3 0.15 
## 6     3         4 0.737
```

``` r
norms_before %>% 
  ungroup() %>% 
  group_by(prof, education) %>% 
  summarise(Prop = round(n()/45, 3))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof and education.
## i Output is grouped by prof.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof, education))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## # A tibble: 4 x 3
## # Groups:   prof [1]
##    prof education  Prop
##   <dbl>     <int> <dbl>
## 1     1        -1 0.022
## 2     1         2 0.022
## 3     1         3 0.022
## 4     1         4 0.933
```

``` r
tt_stud %>% 
  ungroup() %>% 
  group_by(education) %>% 
  summarise(Prop = round(n()/166, 3))
```

```
## # A tibble: 5 x 2
##   education  Prop
##       <dbl> <dbl>
## 1        -1 0.012
## 2         0 0.006
## 3         2 0.024
## 4         3 0.518
## 5         4 0.44
```

``` r
norms_stud %>% 
  ungroup() %>% 
  group_by(education) %>% 
  summarise(Prop = round(n()/70, 3))
```

```
## # A tibble: 6 x 2
##   education  Prop
##       <dbl> <dbl>
## 1        -1 0.029
## 2         0 0.014
## 3         1 0.014
## 4         2 0.029
## 5         3 0.429
## 6         4 0.486
```

``` r
tt %>%
  filter(prof==1) %>% 
  ungroup() %>% 
  group_by(job1) %>% 
  summarise(Prop = round(n()/115, 3))
```

```
## # A tibble: 9 x 2
##   job1                   Prop
##   <chr>                 <dbl>
## 1 Chief-Level Executive 0.026
## 2 Consultant            0.104
## 3 Financial Advisor     0.157
## 4 Fund Manager          0.061
## 5 Investment Managent   0.087
## 6 Other                 0.148
## 7 Portfolio Manager     0.191
## 8 Research Analyst      0.13 
## 9 Trader                0.096
```

``` r
tt %>%
  filter(prof==3) %>% 
  ungroup() %>% 
  group_by(job1) %>% 
  summarise(Prop = round(n()/300, 3))
```

```
## # A tibble: 9 x 2
##   job1                   Prop
##   <chr>                 <dbl>
## 1 Chief-Level Executive 0.017
## 2 Consultant            0.09 
## 3 Financial Advisor     0.137
## 4 Fund Manager          0.007
## 5 Investment Managent   0.023
## 6 Other                 0.62 
## 7 Portfolio Manager     0.027
## 8 Research Analyst      0.057
## 9 Trader                0.023
```

``` r
norms %>%
  filter(prof==1) %>% 
  ungroup() %>% 
  group_by(job1) %>% 
  summarise(Prop = round(n()/115, 3))
```

```
## # A tibble: 9 x 2
##   job1                   Prop
##   <chr>                 <dbl>
## 1 Chief-Level Executive 0.026
## 2 Consultant            0.035
## 3 Financial Advisor     0.052
## 4 Fund Manager          0.017
## 5 Investment Managent   0.07 
## 6 Other                 0.096
## 7 Portfolio Manager     0.061
## 8 Research Analyst      0.009
## 9 Trader                0.026
```

## Figure 1

Percentage of dishonest reports as a function of the economic costs of
honesty for financial professionals and students.


``` r
tt_stud_reshaped$treatment1 <- factor(tt_stud_reshaped$treatment, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))
options(repr.plot.width  = 8,
        repr.plot.height = 6)
ggplot(tt_stud_reshaped %>%
         filter(question=="choice") %>%
         mutate(cost = (as.numeric(cost) * (-1) + 5),
                choice = 100-choice*100) %>%         
         group_by(cost, treatment1) %>%
         summarise(choice=mean(choice)),
       aes(x=cost, y=choice, group=treatment1,
           shape=treatment1, color=treatment1)) + 
  geom_line(aes(color=treatment1, linetype=treatment1), size=2) + 
  geom_point(lwd = 2.7) + 
  labs(x="Economic cost of honesty",
       y="Percentage of honest reports") + 
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom",
        legend.key.width = unit(3, "line"),
        legend.title = element_blank(),
        panel.grid.minor.x = element_blank()) + 
  scale_linetype_manual(guide = 'legend', name="Treatment", 
                        values = c("solid",
                                   "dashed",
                                   "dotdash"),
                        labels = c(expression(FIN),
                                   expression(NEU),
                                   expression(ABS))) + 
  scale_color_manual(guide = 'legend', name="Treatment", 
                     values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) + 
  scale_shape_discrete(guide="legend", name="Treatment",
                       labels = c(expression(FIN),
                                  expression(NEU),
                                  expression(ABS))) +     
  ylim(0, 100) + 
  labs(title = "STUD")
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by cost and treatment1.
## i Output is grouped by cost.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(cost, treatment1))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## i Please use `linewidth` instead.
## This warning is displayed once per session.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-22-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/PercLies_STUD.pdf", width=20, height=15, units="cm")
```


``` r
tt_before_reshaped$treatment1 <- factor(tt_before_reshaped$treatment, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))
tt_pf_reshaped$treatment1 <- factor(tt_pf_reshaped$treatment, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))
options(repr.plot.width  = 8,
        repr.plot.height = 6)
ggplot(rbind(tt_before_reshaped, tt_pf_reshaped) %>%
         filter(question=="choice",
                treatment=="su_ha_neu"|treatment=="su_ha_abs"|treatment=="sh_sev_fin") %>%
         mutate(cost = ((as.numeric(cost) * (-1) + 5)*2),
                choice = 100 - choice*100) %>%         
         group_by(cost, treatment1) %>%
         summarise(choice=mean(choice)),
       aes(x=cost, y=choice, group=treatment1,
           shape=treatment1, color=treatment1)) + 
  geom_line(aes(color=treatment1, linetype=treatment1), size=2) + 
  geom_point(lwd = 2.7) + 
  labs(x="Economic cost of honesty",
       y="Percentage of honest reports") + 
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom",
        legend.key.width = unit(3, "line"),
        legend.title = element_blank(),
        panel.grid.minor.x = element_blank()) + 
  scale_linetype_manual(guide = 'legend', name="Treatment", 
                        values = c("solid",
                                   "dashed",
                                   "dotdash"),
                        labels = c(expression(FIN),
                                   expression(NEU),
                                   expression(ABS))) + 
  scale_color_manual(guide = 'legend', name="Treatment", 
                     values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU),
                                expression(ABS))) + 
  scale_shape_discrete(guide="legend", name="Treatment",
                       labels = c(expression(FIN),
                                  expression(NEU),
                                  expression(ABS))) +   
  ylim(0, 100) + 
  labs(title = "PROF")
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by cost and treatment1.
## i Output is grouped by cost.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(cost, treatment1))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-23-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/PercLies_PROF3treat.pdf", width=20, height=15, units="cm")
```

## Figure 2


``` r
tt_before_reshaped$treatment1 <- factor(tt_before_reshaped$treatment, levels = c('sh_sev_fin', 'sh_ha_fin', 'su_ha_neu',
                                                                         'su_sev_fin', 'su_ha_abs', 'su_ha_fin'))
tt_pf_reshaped$treatment1 <- factor(tt_pf_reshaped$treatment, levels = c('sh_sev_fin', 'sh_ha_fin', 'su_ha_neu',
                                                                         'su_sev_fin', 'su_ha_abs', 'su_ha_fin'))
options(repr.plot.width  = 8,
        repr.plot.height = 6)
ggplot(rbind(tt_before_reshaped, tt_pf_reshaped) %>%
         filter(question=="choice") %>%
         mutate(cost = (as.numeric(cost) * (-1) + 5) * 2,
                choice = 100 - choice*100) %>%         
         group_by(cost, treatment1) %>%
         summarise(choice=mean(choice)),
       aes(x=cost, y=choice, group=treatment1,
           shape=treatment1, color=treatment1)) + 
  geom_line(aes(color=treatment1, linetype=treatment1), size=2) + 
  geom_point(lwd = 2.7) + 
  labs(x="Economic cost of honesty",
       y="Percentage of honest reports") + 
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom",
        legend.key.width = unit(3, "line"),
        legend.title = element_blank(),
        panel.grid.minor.x = element_blank()) + 
  scale_linetype_manual(guide = 'legend', name="Treatment", 
                        values = c("solid",
                                   "twodash",
                                   "dashed",
                                   "dotted",
                                   "dotdash",
                                   "12345678"),
                        labels = c(expression(FIN),
                                   expression(FIN[HA]^MANY),
                                   expression(NEU),
                                   expression(FIN[SEV]^ONE),
                                   expression(ABS),
                                   expression(FIN[HA]^ONE))) + 
  scale_color_manual(guide = 'legend', name="Treatment", 
                     values=viridis(n = 6),
                     labels = c(expression(FIN),
                                expression(FIN[HA]^MANY),
                                expression(NEU),
                                expression(FIN[SEV]^ONE),
                                expression(ABS),
                                expression(FIN[HA]^ONE))) + 
  scale_shape_manual(guide="legend", name="Treatment",
                       values=c(16, 1, 17,  5, 15, 6),
                       labels = c(expression(FIN),
                                  expression(FIN[HA]^MANY),
                                  expression(NEU),
                                  expression(FIN[SEV]^ONE),
                                  expression(ABS),
                                  expression(FIN[HA]^ONE))) +
  ylim(0, 100) + 
  labs(title = "PROF")
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by cost and treatment1.
## i Output is grouped by cost.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(cost, treatment1))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-24-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/PercLies_PROF6treat.pdf", width=20, height=15, units="cm")
```

## Table B4

Linear estimation of the probability of an honest report for financial
pro- fessionals and students


``` r
reshaped$treatment1 <- factor(reshaped$treatment, levels = c('su_ha_abs', 'su_ha_neu', 'sh_sev_fin',
                                                             'su_ha_fin', 'sh_ha_fin', 'su_sev_fin'))

reshaped$choice1 <- 1 - reshaped$choice

reg1cl <- felm(choice1 ~ as.numeric(cost) + treatment1|0|0|subject, data = reshaped %>% 
                 filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg2cl <- felm(choice1 ~ as.numeric(cost) + treatment1 + prof1|0|0|subject, data = reshaped %>% 
                 filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg3cl <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 |0|0|subject, data = reshaped %>% 
                 filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg4cl <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 + female + risk + age + investment +  
                 pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 +
                 order|0|0|subject,
           data = reshaped %>% 
                 filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs')) 

stargazer(reg2cl, reg3cl, reg4cl, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Honest report")
```

```
## 
## ================================================================================
##                                      Dependent variable: Honest report          
##                            -----------------------------------------------------
##                                                   choice1                       
##                                   (1)               (2)               (3)       
## --------------------------------------------------------------------------------
## as.numeric(cost)               -0.152***         -0.152***         -0.152***    
##                                 (0.007)           (0.007)           (0.007)     
##                                                                                 
## treatment1su_ha_neu            0.119***            0.061             0.071      
##                                 (0.040)           (0.050)           (0.054)     
##                                                                                 
## treatment1sh_sev_fin           0.145***            0.028             0.024      
##                                 (0.038)           (0.043)           (0.046)     
##                                                                                 
## prof1                          0.247***           0.135**          0.212***     
##                                 (0.030)           (0.055)           (0.057)     
##                                                                                 
## female                                                               0.007      
##                                                                     (0.035)     
##                                                                                 
## risk                                                               -0.026**     
##                                                                     (0.011)     
##                                                                                 
## age                                                                -0.00005     
##                                                                    (0.00003)    
##                                                                                 
## investment                                                          -0.071*     
##                                                                     (0.038)     
##                                                                                 
## pref1_1                                                              0.010      
##                                                                     (0.013)     
##                                                                                 
## pref1_2                                                             -0.003      
##                                                                     (0.013)     
##                                                                                 
## pref1_3                                                             -0.002      
##                                                                     (0.012)     
##                                                                                 
## pref1_4                                                            0.055***     
##                                                                     (0.011)     
##                                                                                 
## pref2_1                                                             -0.021      
##                                                                     (0.018)     
##                                                                                 
## pref2_2                                                             -0.013      
##                                                                     (0.012)     
##                                                                                 
## pref2_3                                                             -0.009      
##                                                                     (0.010)     
##                                                                                 
## order                                                              -0.064**     
##                                                                     (0.030)     
##                                                                                 
## treatment1su_ha_neu:prof1                          0.109             0.064      
##                                                   (0.078)           (0.078)     
##                                                                                 
## treatment1sh_sev_fin:prof1                       0.205***           0.176**     
##                                                   (0.072)           (0.072)     
##                                                                                 
## Constant                       0.540***          0.599***          0.638***     
##                                 (0.037)           (0.037)           (0.135)     
##                                                                                 
## --------------------------------------------------------------------------------
## Observations                     1,945             1,945             1,945      
## R2                               0.265             0.272             0.317      
## Adjusted R2                      0.264             0.270             0.310      
## Residual Std. Error        0.428 (df = 1940) 0.427 (df = 1938) 0.415 (df = 1926)
## ================================================================================
## Note:                                                *p<0.1; **p<0.05; ***p<0.01
```


``` r
# Wald tests for Table 3

library(car)

# NEU+PROF vs. NEU+STUD
linearHypothesis(reg3cl, "prof1 + treatment1su_ha_neu:prof1")
```

```
## 
## Linear hypothesis test:
## prof1  + treatment1su_ha_neu:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1939                         
## 2   1938  1 19.022  1.292e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
linearHypothesis(reg4cl, "prof1 + treatment1su_ha_neu:prof1")
```

```
## 
## Linear hypothesis test:
## prof1  + treatment1su_ha_neu:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 + female + risk + 
##     age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + 
##     pref2_1 + pref2_2 + pref2_3 + order | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1927                         
## 2   1926  1 23.219  1.446e-06 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
# FIN+PROF vs. FIN+STUD
linearHypothesis(reg3cl, "prof1 + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## prof1  + treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1939                         
## 2   1938  1 53.084  3.196e-13 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
linearHypothesis(reg4cl, "prof1 + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## prof1  + treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 + female + risk + 
##     age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + 
##     pref2_1 + pref2_2 + pref2_3 + order | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1927                         
## 2   1926  1 67.014  2.696e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
# ABS+PROF vs. NEU+PROF
linearHypothesis(reg3cl, "treatment1su_ha_neu + treatment1su_ha_neu:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1su_ha_neu  + treatment1su_ha_neu:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 | 0 | 0 | subject
## 
##   Res.Df Df Chisq Pr(>Chisq)   
## 1   1939                       
## 2   1938  1 8.046    0.00456 **
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
linearHypothesis(reg4cl, "treatment1su_ha_neu + treatment1su_ha_neu:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1su_ha_neu  + treatment1su_ha_neu:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 + female + risk + 
##     age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + 
##     pref2_1 + pref2_2 + pref2_3 + order | 0 | 0 | subject
## 
##   Res.Df Df Chisq Pr(>Chisq)  
## 1   1927                      
## 2   1926  1 5.728     0.0167 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
# ABS+PROF vs. FIN+PROF
linearHypothesis(reg3cl, "treatment1sh_sev_fin + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1sh_sev_fin  + treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1939                         
## 2   1938  1 16.339  5.297e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
linearHypothesis(reg4cl, "treatment1sh_sev_fin + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1sh_sev_fin  + treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 + female + risk + 
##     age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + 
##     pref2_1 + pref2_2 + pref2_3 + order | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)    
## 1   1927                         
## 2   1926  1 13.412    0.00025 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

``` r
# NEU+PROF vs. FIN+PROF
linearHypothesis(reg3cl, "treatment1su_ha_neu + treatment1su_ha_neu:prof1 = treatment1sh_sev_fin + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1su_ha_neu - treatment1sh_sev_fin  + treatment1su_ha_neu:prof1 - treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)
## 1   1939                     
## 2   1938  1 1.3335     0.2482
```

``` r
linearHypothesis(reg4cl, "treatment1su_ha_neu + treatment1su_ha_neu:prof1 = treatment1sh_sev_fin + treatment1sh_sev_fin:prof1")
```

```
## 
## Linear hypothesis test:
## treatment1su_ha_neu - treatment1sh_sev_fin  + treatment1su_ha_neu:prof1 - treatment1sh_sev_fin:prof1 = 0
## 
## Model 1: restricted model
## Model 2: choice1 ~ as.numeric(cost) + treatment1 * prof1 + female + risk + 
##     age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + 
##     pref2_1 + pref2_2 + pref2_3 + order | 0 | 0 | subject
## 
##   Res.Df Df  Chisq Pr(>Chisq)
## 1   1927                     
## 2   1926  1 1.7437     0.1867
```

## Table B6

Linear estimation of the probability of an honest report for financial
profes- sionals across different treatments.


``` r
reshaped$choice1 <- 1 - reshaped$choice

reg5cl <- felm(choice1 ~ as.numeric(cost) + treatment1|0|0|subject, data = reshaped %>% filter(prof==1|prof==3))
reg7cl <- felm(choice1 ~ as.numeric(cost) + treatment1 + female + risk + age + investment +  
                 pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 +
                 order|0|0|subject, data = reshaped %>% filter(prof==1|prof==3))


stargazer(reg5cl, reg7cl, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Honest report")
```

```
## 
## ========================================================
##                       Dependent variable: Honest report 
##                      -----------------------------------
##                                    choice1              
##                             (1)               (2)       
## --------------------------------------------------------
## as.numeric(cost)         -0.114***         -0.114***    
##                           (0.007)           (0.007)     
##                                                         
## treatment1su_ha_neu      0.170***           0.134**     
##                           (0.060)           (0.057)     
##                                                         
## treatment1sh_sev_fin     0.233***          0.201***     
##                           (0.058)           (0.055)     
##                                                         
## treatment1su_ha_fin      0.273***          0.192***     
##                           (0.060)           (0.061)     
##                                                         
## treatment1sh_ha_fin      0.200***           0.132**     
##                           (0.066)           (0.066)     
##                                                         
## treatment1su_sev_fin     0.233***          0.198***     
##                           (0.067)           (0.066)     
##                                                         
## female                                      -0.045      
##                                             (0.039)     
##                                                         
## risk                                       -0.035***    
##                                             (0.012)     
##                                                         
## age                                       0.00000***    
##                                             (0.000)     
##                                                         
## investment                                  -0.020      
##                                             (0.039)     
##                                                         
## pref1_1                                      0.022      
##                                             (0.015)     
##                                                         
## pref1_2                                     0.0003      
##                                             (0.015)     
##                                                         
## pref1_3                                      0.009      
##                                             (0.013)     
##                                                         
## pref1_4                                    0.056***     
##                                             (0.013)     
##                                                         
## pref2_1                                      0.017      
##                                             (0.020)     
##                                                         
## pref2_2                                    -0.032**     
##                                             (0.014)     
##                                                         
## pref2_3                                     -0.023*     
##                                             (0.012)     
##                                                         
## order                                       -0.006      
##                                             (0.034)     
##                                                         
## Constant                 0.658***          0.514***     
##                           (0.047)           (0.158)     
##                                                         
## --------------------------------------------------------
## Observations               2,075             2,075      
## R2                         0.142             0.198      
## Adjusted R2                0.139             0.191      
## Residual Std. Error  0.451 (df = 2068) 0.437 (df = 2056)
## ========================================================
## Note:                        *p<0.1; **p<0.05; ***p<0.01
```

## Table 4

Linear estimation of the proportion of honest reports for financial
professionals across different treatments.


``` r
tt$treatment1 <- factor(tt$treatment, levels = c('su_ha_abs', 'su_ha_neu', 'sh_sev_fin',
                                                             'su_ha_fin', 'sh_ha_fin', 'su_sev_fin'))

tt$truths <- 1 - tt$lies/5

regsub5cl <- felm(truths ~ treatment1|0|0|subject, data = tt %>% filter(prof==1|prof==3))
regsub7cl <- felm(truths ~ treatment1 + female + risk + age + investment +  
                 pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 +
                 order|0|0|subject, data = tt %>% filter(prof==1|prof==3))


stargazer(regsub5cl, regsub7cl, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Proportion of honest reports")
```

```
## 
## ======================================================================
##                      Dependent variable: Proportion of honest reports 
##                      -------------------------------------------------
##                                           truths                      
##                                (1)                      (2)           
## ----------------------------------------------------------------------
## treatment1su_ha_neu          0.170***                 0.134**         
##                              (0.060)                  (0.058)         
##                                                                       
## treatment1sh_sev_fin         0.233***                 0.201***        
##                              (0.058)                  (0.056)         
##                                                                       
## treatment1su_ha_fin          0.273***                 0.192***        
##                              (0.061)                  (0.062)         
##                                                                       
## treatment1sh_ha_fin          0.200***                 0.132**         
##                              (0.067)                  (0.067)         
##                                                                       
## treatment1su_sev_fin         0.233***                 0.198***        
##                              (0.067)                  (0.068)         
##                                                                       
## female                                                 -0.045         
##                                                       (0.039)         
##                                                                       
## risk                                                 -0.035***        
##                                                       (0.013)         
##                                                                       
## age                                                  0.00000***       
##                                                       (0.000)         
##                                                                       
## investment                                             -0.020         
##                                                       (0.040)         
##                                                                       
## pref1_1                                                0.022          
##                                                       (0.016)         
##                                                                       
## pref1_2                                                0.0003         
##                                                       (0.016)         
##                                                                       
## pref1_3                                                0.009          
##                                                       (0.013)         
##                                                                       
## pref1_4                                               0.056***        
##                                                       (0.014)         
##                                                                       
## pref2_1                                                0.017          
##                                                       (0.020)         
##                                                                       
## pref2_2                                               -0.032**        
##                                                       (0.014)         
##                                                                       
## pref2_3                                               -0.023*         
##                                                       (0.012)         
##                                                                       
## order                                                  -0.006         
##                                                       (0.034)         
##                                                                       
## Constant                     0.430***                  0.285*         
##                              (0.045)                  (0.160)         
##                                                                       
## ----------------------------------------------------------------------
## Observations                   415                      415           
## R2                            0.054                    0.155          
## Adjusted R2                   0.043                    0.119          
## Residual Std. Error      0.358 (df = 409)         0.343 (df = 397)    
## ======================================================================
## Note:                                      *p<0.1; **p<0.05; ***p<0.01
```

## Table B2


``` r
# ONLY BEFORE-POOL

reg1clBEFORE <- felm(choice1 ~ as.numeric(cost) + treatment1|0|0|subject, 
               data = reshaped %>%
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg2clBEFORE <- felm(choice1 ~ as.numeric(cost) + treatment1 + prof1|0|0|subject, 
               data = reshaped %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg3clBEFORE <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 |0|0|subject, 
               data = reshaped %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg4clBEFORE <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 + female + risk + age + investment +  pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order|0|0|subject,
               data = reshaped %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs')) 

stargazer(reg1clBEFORE, reg2clBEFORE, reg3clBEFORE, reg4clBEFORE, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Honest report")
```

```
## 
## ==================================================================================================
##                                               Dependent variable: Honest report                   
##                            -----------------------------------------------------------------------
##                                                            choice1                                
##                                   (1)               (2)               (3)               (4)       
## --------------------------------------------------------------------------------------------------
## as.numeric(cost)               -0.170***         -0.170***         -0.170***         -0.170***    
##                                 (0.008)           (0.008)           (0.008)           (0.008)     
##                                                                                                   
## treatment1su_ha_neu             0.103**           0.091**            0.061             0.060      
##                                 (0.043)           (0.043)           (0.050)           (0.052)     
##                                                                                                   
## treatment1sh_sev_fin           0.129***          0.125***            0.028             0.006      
##                                 (0.044)           (0.041)           (0.043)           (0.046)     
##                                                                                                   
## prof1                                            0.195***            0.082            0.156**     
##                                                   (0.036)           (0.067)           (0.070)     
##                                                                                                   
## female                                                                                 0.002      
##                                                                                       (0.040)     
##                                                                                                   
## risk                                                                                  -0.020*     
##                                                                                       (0.012)     
##                                                                                                   
## age                                                                                  -0.0001**    
##                                                                                      (0.00003)    
##                                                                                                   
## investment                                                                            -0.066      
##                                                                                       (0.046)     
##                                                                                                   
## pref1_1                                                                                0.005      
##                                                                                       (0.014)     
##                                                                                                   
## pref1_2                                                                                0.008      
##                                                                                       (0.014)     
##                                                                                                   
## pref1_3                                                                               0.0005      
##                                                                                       (0.014)     
##                                                                                                   
## pref1_4                                                                              0.035***     
##                                                                                       (0.013)     
##                                                                                                   
## pref2_1                                                                               -0.031      
##                                                                                       (0.021)     
##                                                                                                   
## pref2_2                                                                               -0.019      
##                                                                                       (0.012)     
##                                                                                                   
## pref2_3                                                                                0.006      
##                                                                                       (0.011)     
##                                                                                                   
## order                                                                                 -0.037      
##                                                                                       (0.033)     
##                                                                                                   
## treatment1su_ha_neu:prof1                                            0.083             0.063      
##                                                                     (0.091)           (0.092)     
##                                                                                                   
## treatment1sh_sev_fin:prof1                                         0.248***          0.250***     
##                                                                     (0.089)           (0.090)     
##                                                                                                   
## Constant                       0.665***          0.591***          0.634***          0.757***     
##                                 (0.037)           (0.040)           (0.039)           (0.141)     
##                                                                                                   
## --------------------------------------------------------------------------------------------------
## Observations                     1,405             1,405             1,405             1,405      
## R2                               0.252             0.290             0.300             0.324      
## Adjusted R2                      0.250             0.288             0.297             0.315      
## Residual Std. Error        0.425 (df = 1401) 0.414 (df = 1400) 0.412 (df = 1398) 0.406 (df = 1386)
## ==================================================================================================
## Note:                                                                  *p<0.1; **p<0.05; ***p<0.01
```

``` r
# ONLY PROLIFIC-POOL

reg1clPF <- felm(choice1 ~ as.numeric(cost) + treatment1|0|0|subject, 
               data = reshaped %>%
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg2clPF <- felm(choice1 ~ as.numeric(cost) + treatment1 + prof1|0|0|subject, 
               data = reshaped %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg3clPF <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 |0|0|subject, 
               data = reshaped %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg4clPF <- felm(choice1 ~ as.numeric(cost) + treatment1*prof1 + female + risk + age + investment +  pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order|0|0|subject,
               data = reshaped %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs')) 

stargazer(reg1clPF, reg2clPF, reg3clPF, reg4clPF, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Honest report")
```

```
## 
## ==================================================================================================
##                                               Dependent variable: Honest report                   
##                            -----------------------------------------------------------------------
##                                                            choice1                                
##                                   (1)               (2)               (3)               (4)       
## --------------------------------------------------------------------------------------------------
## as.numeric(cost)               -0.151***         -0.151***         -0.151***         -0.151***    
##                                 (0.008)           (0.008)           (0.008)           (0.008)     
##                                                                                                   
## treatment1su_ha_neu             0.117**           0.118**            0.061             0.068      
##                                 (0.051)           (0.046)           (0.050)           (0.053)     
##                                                                                                   
## treatment1sh_sev_fin           0.132***           0.081*             0.028             0.027      
##                                 (0.046)           (0.042)           (0.043)           (0.046)     
##                                                                                                   
## prof1                                            0.313***          0.202***          0.229***     
##                                                   (0.040)           (0.073)           (0.071)     
##                                                                                                   
## female                                                                                 0.039      
##                                                                                       (0.037)     
##                                                                                                   
## risk                                                                                  -0.009      
##                                                                                       (0.012)     
##                                                                                                   
## age                                                                                  -0.0001**    
##                                                                                      (0.00003)    
##                                                                                                   
## investment                                                                            -0.051      
##                                                                                       (0.039)     
##                                                                                                   
## pref1_1                                                                                0.006      
##                                                                                       (0.015)     
##                                                                                                   
## pref1_2                                                                               -0.015      
##                                                                                       (0.016)     
##                                                                                                   
## pref1_3                                                                               -0.0003     
##                                                                                       (0.015)     
##                                                                                                   
## pref1_4                                                                              0.051***     
##                                                                                       (0.014)     
##                                                                                                   
## pref2_1                                                                               -0.018      
##                                                                                       (0.021)     
##                                                                                                   
## pref2_2                                                                               -0.002      
##                                                                                       (0.015)     
##                                                                                                   
## pref2_3                                                                               -0.009      
##                                                                                       (0.011)     
##                                                                                                   
## order                                                                                -0.086**     
##                                                                                       (0.036)     
##                                                                                                   
## treatment1su_ha_neu:prof1                                            0.173             0.121      
##                                                                     (0.106)           (0.102)     
##                                                                                                   
## treatment1sh_sev_fin:prof1                                           0.145             0.132      
##                                                                     (0.093)           (0.089)     
##                                                                                                   
## Constant                       0.664***          0.561***          0.597***          0.574***     
##                                 (0.038)           (0.040)           (0.040)           (0.159)     
##                                                                                                   
## --------------------------------------------------------------------------------------------------
## Observations                     1,370             1,370             1,370             1,370      
## R2                               0.199             0.291             0.296             0.339      
## Adjusted R2                      0.197             0.289             0.293             0.330      
## Residual Std. Error        0.446 (df = 1366) 0.420 (df = 1365) 0.418 (df = 1363) 0.407 (df = 1351)
## ==================================================================================================
## Note:                                                                  *p<0.1; **p<0.05; ***p<0.01
```


``` r
tt$treatment1 <- factor(tt$treatment, levels = c('su_ha_abs', 
                                                 'su_ha_neu', 
                                                 'sh_sev_fin'))

tt$truths <- 1 - tt$lies/5

# ONLY BEFORE-POOL

regsub1clBEFORE <- felm(truths ~ treatment1|0|0|subject, 
               data = tt %>%
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub2clBEFORE <- felm(truths ~ treatment1 + prof1|0|0|subject, 
               data = tt %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub3clBEFORE <- felm(truths ~ treatment1*prof1 |0|0|subject, 
               data = tt %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub4clBEFORE <- felm(truths ~ treatment1*prof1 + female + risk + age + investment +  pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order|0|0|subject,
               data = tt %>% 
                 filter(prof!=3,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs')) 

stargazer(regsub1clBEFORE, regsub2clBEFORE, regsub3clBEFORE, regsub4clBEFORE, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Proportion of honest reports")
```

```
## 
## ==============================================================================================
##                                     Dependent variable: Proportion of honest reports          
##                            -------------------------------------------------------------------
##                                                          truths                               
##                                  (1)              (2)              (3)              (4)       
## ----------------------------------------------------------------------------------------------
## treatment1su_ha_neu            0.103**          0.091**           0.061            0.060      
##                                (0.043)          (0.043)          (0.051)          (0.053)     
##                                                                                               
## treatment1sh_sev_fin           0.129***         0.125***          0.028            0.006      
##                                (0.044)          (0.041)          (0.043)          (0.047)     
##                                                                                               
## prof1                                           0.195***          0.082           0.156**     
##                                                 (0.037)          (0.068)          (0.072)     
##                                                                                               
## female                                                                             0.002      
##                                                                                   (0.041)     
##                                                                                               
## risk                                                                              -0.020*     
##                                                                                   (0.012)     
##                                                                                               
## age                                                                              -0.0001**    
##                                                                                  (0.00003)    
##                                                                                               
## investment                                                                         -0.066     
##                                                                                   (0.047)     
##                                                                                               
## pref1_1                                                                            0.005      
##                                                                                   (0.014)     
##                                                                                               
## pref1_2                                                                            0.008      
##                                                                                   (0.015)     
##                                                                                               
## pref1_3                                                                            0.0005     
##                                                                                   (0.014)     
##                                                                                               
## pref1_4                                                                           0.035***    
##                                                                                   (0.013)     
##                                                                                               
## pref2_1                                                                            -0.031     
##                                                                                   (0.021)     
##                                                                                               
## pref2_2                                                                            -0.019     
##                                                                                   (0.013)     
##                                                                                               
## pref2_3                                                                            0.006      
##                                                                                   (0.012)     
##                                                                                               
## order                                                                              -0.037     
##                                                                                   (0.034)     
##                                                                                               
## treatment1su_ha_neu:prof1                                         0.083            0.063      
##                                                                  (0.091)          (0.095)     
##                                                                                               
## treatment1sh_sev_fin:prof1                                       0.248***         0.250***    
##                                                                  (0.090)          (0.092)     
##                                                                                               
## Constant                       0.326***         0.251***         0.295***         0.418***    
##                                (0.030)          (0.031)          (0.032)          (0.144)     
##                                                                                               
## ----------------------------------------------------------------------------------------------
## Observations                     281              281              281              281       
## R2                              0.033            0.132            0.159            0.221      
## Adjusted R2                     0.026            0.122            0.144            0.170      
## Residual Std. Error        0.301 (df = 278) 0.285 (df = 277) 0.282 (df = 275) 0.277 (df = 263)
## ==============================================================================================
## Note:                                                              *p<0.1; **p<0.05; ***p<0.01
```

``` r
# ONLY PROLIFIC-POOL

regsub1clPF <- felm(truths ~ treatment1|0|0|subject, 
               data = tt %>%
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub2clPF <- felm(truths ~ treatment1 + prof1|0|0|subject, 
               data = tt %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub3clPF <- felm(truths ~ treatment1*prof1 |0|0|subject, 
               data = tt %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
regsub4clPF <- felm(truths ~ treatment1*prof1 + female + risk + age + investment +  pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order|0|0|subject,
               data = tt %>% 
                 filter(prof!=1,
                        treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs')) 

stargazer(regsub1clPF, regsub2clPF, regsub3clPF, regsub4clPF, digits=3, align=FALSE, type="text",
         dep.var.caption = "Dependent variable: Proportion of honest reports")
```

```
## 
## ==============================================================================================
##                                     Dependent variable: Proportion of honest reports          
##                            -------------------------------------------------------------------
##                                                          truths                               
##                                  (1)              (2)              (3)              (4)       
## ----------------------------------------------------------------------------------------------
## treatment1su_ha_neu            0.117**          0.118**           0.061            0.068      
##                                (0.051)          (0.046)          (0.051)          (0.055)     
##                                                                                               
## treatment1sh_sev_fin           0.132***          0.081*           0.028            0.027      
##                                (0.046)          (0.042)          (0.043)          (0.048)     
##                                                                                               
## prof1                                           0.313***         0.202***         0.229***    
##                                                 (0.040)          (0.074)          (0.073)     
##                                                                                               
## female                                                                             0.039      
##                                                                                   (0.038)     
##                                                                                               
## risk                                                                               -0.009     
##                                                                                   (0.013)     
##                                                                                               
## age                                                                              -0.0001**    
##                                                                                  (0.00003)    
##                                                                                               
## investment                                                                         -0.051     
##                                                                                   (0.040)     
##                                                                                               
## pref1_1                                                                            0.006      
##                                                                                   (0.016)     
##                                                                                               
## pref1_2                                                                            -0.015     
##                                                                                   (0.016)     
##                                                                                               
## pref1_3                                                                           -0.0003     
##                                                                                   (0.016)     
##                                                                                               
## pref1_4                                                                           0.051***    
##                                                                                   (0.014)     
##                                                                                               
## pref2_1                                                                            -0.018     
##                                                                                   (0.022)     
##                                                                                               
## pref2_2                                                                            -0.002     
##                                                                                   (0.015)     
##                                                                                               
## pref2_3                                                                            -0.009     
##                                                                                   (0.012)     
##                                                                                               
## order                                                                             -0.086**    
##                                                                                   (0.037)     
##                                                                                               
## treatment1su_ha_neu:prof1                                         0.173            0.121      
##                                                                  (0.107)          (0.105)     
##                                                                                               
## treatment1sh_sev_fin:prof1                                        0.145            0.132      
##                                                                  (0.094)          (0.091)     
##                                                                                               
## Constant                       0.361***         0.258***         0.295***          0.271*     
##                                (0.032)          (0.031)          (0.032)          (0.162)     
##                                                                                               
## ----------------------------------------------------------------------------------------------
## Observations                     274              274              274              274       
## R2                              0.029            0.228            0.238            0.331      
## Adjusted R2                     0.022            0.219            0.224            0.286      
## Residual Std. Error        0.335 (df = 271) 0.300 (df = 270) 0.299 (df = 268) 0.286 (df = 256)
## ==============================================================================================
## Note:                                                              *p<0.1; **p<0.05; ***p<0.01
```

## Table B3

Ordered logit regression on the proportion of honest reports for
financial professionals and students.


``` r
tt$treatment1 <- factor(tt$treatment, levels = c('su_ha_abs', 
                                                 'su_ha_neu', 
                                                 'sh_sev_fin'))

tt$truths <- factor(1 - tt$lies/5, levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0))

reg1ologit <- polr(truths ~ treatment1, Hess = TRUE,
                  data = tt %>% filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg1ologit.or <- exp(coef(reg1ologit))
reg2ologit <- polr(truths ~ treatment1 + prof1,  Hess = TRUE,
                  data = tt %>% filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg2ologit.or <- exp(coef(reg2ologit))
reg3ologit <- polr(truths ~ treatment1*prof1,  Hess = TRUE,
                  data = tt %>% filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg3ologit.or <- exp(coef(reg3ologit))
reg4ologit <- polr(truths ~ treatment1*prof1 + female + risk + age + investment + order +  pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3, Hess = TRUE,
                  data = tt %>% filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'))
reg4ologit.or <- exp(coef(reg4ologit))

stargazer(reg2ologit, reg3ologit, reg4ologit, type="text",
          coef = list(reg2ologit.or, reg3ologit.or, reg4ologit.or),
          dep.var.caption = "Dependent variable: Proportion of honest reports")
```

```
## 
## =============================================================================
##                             Dependent variable: Proportion of honest reports 
##                            --------------------------------------------------
##                                                  truths                      
##                                  (1)              (2)              (3)       
## -----------------------------------------------------------------------------
## treatment1su_ha_neu            1.821***         1.257***         1.327***    
##                                (0.234)          (0.337)          (0.361)     
##                                                                              
## treatment1sh_sev_fin           2.199***         1.198***         1.149***    
##                                (0.226)          (0.325)          (0.344)     
##                                                                              
## prof1                          3.535***         1.804***         2.793***    
##                                (0.190)          (0.336)          (0.366)     
##                                                                              
## female                                                           1.147***    
##                                                                  (0.218)     
##                                                                              
## risk                                                             0.860***    
##                                                                  (0.071)     
##                                                                              
## age                                                              0.998***    
##                                                                  (0.002)     
##                                                                              
## investment                                                       0.723***    
##                                                                  (0.243)     
##                                                                              
## order                                                            0.635***    
##                                                                  (0.190)     
##                                                                              
## pref1_1                                                          1.046***    
##                                                                  (0.078)     
##                                                                              
## pref1_2                                                          0.955***    
##                                                                  (0.081)     
##                                                                              
## pref1_3                                                          1.015***    
##                                                                  (0.075)     
##                                                                              
## pref1_4                                                          1.351***    
##                                                                  (0.075)     
##                                                                              
## pref2_1                                                          0.908***    
##                                                                  (0.108)     
##                                                                              
## pref2_2                                                          0.926***    
##                                                                  (0.074)     
##                                                                              
## pref2_3                                                          0.958***    
##                                                                  (0.065)     
##                                                                              
## treatment1su_ha_neu:prof1                       2.098***         1.839***    
##                                                 (0.467)          (0.489)     
##                                                                              
## treatment1sh_sev_fin:prof1                      3.197***         3.068***    
##                                                 (0.451)          (0.470)     
##                                                                              
## -----------------------------------------------------------------------------
## Observations                     389              389              389       
## =============================================================================
## Note:                                             *p<0.1; **p<0.05; ***p<0.01
```

## Table B5

Logistic regression on the probability of an honest report for financial
professionals and students.


``` r
reshaped$treatment1 <- factor(reshaped$treatment, levels = c('su_ha_abs', 
                                                 'su_ha_neu', 
                                                 'sh_sev_fin'))

reshaped$choice1 <- 1 - reshaped$choice

logit1cl <- glm(choice1 ~ as.numeric(cost) + treatment1, 
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'), family="binomial")
logit1clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1, 
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'),
                                  cluster="subject", family="binomial")
```

```
## Registered S3 method overwritten by 'broom':
##   method    from
##   nobs.felm lfe
```

```
## Registered S3 method overwritten by 'lme4':
##   method           from
##   na.action.merMod car
```

``` r
logit1cl.or <- exp(coef(logit1cl))

logit2cl <- glm(choice1 ~ as.numeric(cost) + treatment1 + prof1,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'), family="binomial")
logit2clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1 + prof1,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'),
                                  cluster="subject", family="binomial")
logit2cl.or <- exp(coef(logit2cl))

logit3cl <- glm(choice1 ~ as.numeric(cost) + treatment1*prof1,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'), family="binomial")
logit3clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1*prof1,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'),
                                  cluster="subject", family="binomial")
logit3cl.or <- exp(coef(logit3cl))

logit4cl <- glm(choice1 ~ as.numeric(cost) + treatment1*prof1 + female + risk + age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'), family="binomial")
logit4clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1*prof1 + female + risk + age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order,
                                  data = reshaped %>%
                                    filter(treatment1 == 'sh_sev_fin'|treatment1 == 'su_ha_neu'|treatment1 == 'su_ha_abs'),
                                  cluster="subject", family="binomial")
logit4cl.or <- exp(coef(logit4cl))

stargazer(logit2cl, logit3cl, logit4cl,
          coef = list(
            logit2cl.or,
            logit3cl.or,
            logit4cl.or
          ),
          se = list(
            as.data.frame(summary(logit2clse))[, 2],
            as.data.frame(summary(logit3clse))[, 2],
            as.data.frame(summary(logit4clse))[, 2]
          ),
          align=TRUE, type="text",
          title = "Logistic regression with standard errors clustered at the subject-level",
          dep.var.caption = "Dependent variable: Prob(Dishonest report)")
```

```
##                        Estimate Std. Error     z value     Pr(>|z|)
## (Intercept)           0.1132708 0.18624612   0.6081779 5.430695e-01
## as.numeric(cost)     -0.7735726 0.04483387 -17.2542006 1.040518e-66
## treatment1su_ha_neu   0.6535557 0.22111823   2.9556843 3.119763e-03
## treatment1sh_sev_fin  0.7928688 0.21147642   3.7492068 1.773947e-04
## prof1                 1.3159324 0.16755562   7.8537054 4.039225e-15
##                              Estimate Std. Error     z value     Pr(>|z|)
## (Intercept)                 0.4531716  0.2012703   2.2515574 2.435026e-02
## as.numeric(cost)           -0.7822548  0.0461984 -16.9325095 2.590944e-64
## treatment1su_ha_neu         0.3483699  0.2839707   1.2267812 2.199049e-01
## treatment1sh_sev_fin        0.1646237  0.2498021   0.6590164 5.098853e-01
## prof1                       0.7450071  0.2974886   2.5043215 1.226865e-02
## treatment1su_ha_neu:prof1   0.5402620  0.4278144   1.2628419 2.066460e-01
## treatment1sh_sev_fin:prof1  1.0644131  0.4034071   2.6385584 8.325937e-03
##                                 Estimate  Std. Error     z value     Pr(>|z|)
## (Intercept)                 0.7540718225 0.789242925   0.9554369 3.393568e-01
## as.numeric(cost)           -0.8424867102 0.048957251 -17.2086196 2.288213e-66
## treatment1su_ha_neu         0.4007228426 0.323276902   1.2395653 2.151362e-01
## treatment1sh_sev_fin        0.1376771310 0.281602670   0.4889056 6.249085e-01
## prof1                       1.2703477226 0.337245970   3.7668285 1.653345e-04
## female                      0.0407163785 0.206038152   0.1976157 8.433457e-01
## risk                       -0.1653175940 0.064334833  -2.5696437 1.018032e-02
## age                        -0.0009157397 0.000602278  -1.5204601 1.283954e-01
## investment                 -0.4476355310 0.229112931  -1.9537768 5.072762e-02
## pref1_1                     0.0629882643 0.077659105   0.8110867 4.173159e-01
## pref1_2                    -0.0195270494 0.077039905  -0.2534667 7.999076e-01
## pref1_3                    -0.0150536252 0.072534061  -0.2075387 8.355892e-01
## pref1_4                     0.3406081609 0.069502910   4.9006316 9.552903e-07
## pref2_1                    -0.1318361772 0.106279144  -1.2404708 2.148013e-01
## pref2_2                    -0.0775083934 0.071409947  -1.0854005 2.777443e-01
## pref2_3                    -0.0529731099 0.060499720  -0.8755926 3.812515e-01
## order                      -0.3875047385 0.178718552  -2.1682401 3.014042e-02
## treatment1su_ha_neu:prof1   0.3409228132 0.455631021   0.7482432 4.543135e-01
## treatment1sh_sev_fin:prof1  0.9864734209 0.428466996   2.3023323 2.131644e-02
## 
## Logistic regression with standard errors clustered at the subject-level
## =======================================================================
##                             Dependent variable: Prob(Dishonest report) 
##                            --------------------------------------------
##                                              choice1                   
##                                  (1)            (2)            (3)     
## -----------------------------------------------------------------------
## as.numeric(cost)              0.461***        0.457***      0.431***   
##                                (0.045)        (0.046)        (0.049)   
##                                                                        
## treatment1su_ha_neu           1.922***        1.417***      1.493***   
##                                (0.221)        (0.284)        (0.323)   
##                                                                        
## treatment1sh_sev_fin          2.210***        1.179***      1.148***   
##                                (0.211)        (0.250)        (0.282)   
##                                                                        
## prof1                         3.728***        2.106***      3.562***   
##                                (0.168)        (0.297)        (0.337)   
##                                                                        
## female                                                      1.042***   
##                                                              (0.206)   
##                                                                        
## risk                                                        0.848***   
##                                                              (0.064)   
##                                                                        
## age                                                         0.999***   
##                                                              (0.001)   
##                                                                        
## investment                                                  0.639***   
##                                                              (0.229)   
##                                                                        
## pref1_1                                                     1.065***   
##                                                              (0.078)   
##                                                                        
## pref1_2                                                     0.981***   
##                                                              (0.077)   
##                                                                        
## pref1_3                                                     0.985***   
##                                                              (0.073)   
##                                                                        
## pref1_4                                                     1.406***   
##                                                              (0.070)   
##                                                                        
## pref2_1                                                     0.876***   
##                                                              (0.106)   
##                                                                        
## pref2_2                                                     0.925***   
##                                                              (0.071)   
##                                                                        
## pref2_3                                                     0.948***   
##                                                              (0.060)   
##                                                                        
## order                                                       0.679***   
##                                                              (0.179)   
##                                                                        
## treatment1su_ha_neu:prof1                     1.716***      1.406***   
##                                               (0.428)        (0.456)   
##                                                                        
## treatment1sh_sev_fin:prof1                    2.899***      2.682***   
##                                               (0.403)        (0.428)   
##                                                                        
## Constant                      1.120***        1.573***      2.126***   
##                                (0.186)        (0.201)        (0.789)   
##                                                                        
## -----------------------------------------------------------------------
## Observations                    1,945          1,945          1,945    
## Log Likelihood               -1,054.294      -1,046.311     -982.448   
## Akaike Inf. Crit.             2,118.587      2,106.622      2,002.895  
## =======================================================================
## Note:                                       *p<0.1; **p<0.05; ***p<0.01
```

## Table B7

Logistic regression on the probability of an honest report for financial
professionals across different treatments.


``` r
reshaped$treatment1 <- factor(reshaped$treatment,
                              levels = c('su_ha_abs',
                                             'su_ha_neu',
                                             'sh_sev_fin',
                                             'sh_ha_fin',
                                             'su_sev_fin',
                                             'su_ha_fin'))

reshaped$choice1 <- 1 - reshaped$choice

logit5clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1, data = reshaped %>% filter(prof==1|prof==3),
                                  cluster = "subject",
                                  family = "binomial")

logit7clse <- miceadds::glm.cluster(choice1 ~ as.numeric(cost) + treatment1 + female + risk + age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order, data = reshaped %>% filter(prof==1|prof==3),
                                  cluster = "subject",
                                  family = "binomial")
```

```
## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

``` r
logit5cl <- glm(choice1 ~ as.numeric(cost) + treatment1, data = reshaped %>% filter(prof==1|prof==3),
                                  family = "binomial")

logit7cl <- glm(choice1 ~ as.numeric(cost) + treatment1 + female + risk + age + investment + pref1_1 + pref1_2 + pref1_3 + pref1_4 + pref2_1 + pref2_2 + pref2_3 + order, data = reshaped %>% filter(prof==1|prof==3),
                                  family = "binomial")
```

```
## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

``` r
logit5cl.or <- exp(coef(logit5cl))
logit7cl.or <- exp(coef(logit7cl))

stargazer(logit5cl, logit7cl,
          coef = list(
            logit5cl.or,
            logit7cl.or
          ),
          se = list(
            as.data.frame(summary(logit5clse))[, 2],
            as.data.frame(summary(logit7clse))[, 2]
          ),
          align=TRUE, type="text",
          title = "Logistic regression with standard errors clustered at the subject-level",
          dep.var.caption = "Dependent variable: Prob(Honest report)")
```

```
##                        Estimate Std. Error    z value     Pr(>|z|)
## (Intercept)           0.7600832 0.21230657   3.580121 3.434350e-04
## as.numeric(cost)     -0.5422640 0.03479591 -15.584131 9.332448e-55
## treatment1su_ha_neu   0.7874422 0.28150642   2.797244 5.154056e-03
## treatment1sh_sev_fin  1.0914780 0.27780726   3.928904 8.533396e-05
## treatment1sh_ha_fin   0.9306492 0.31746194   2.931530 3.372969e-03
## treatment1su_sev_fin  1.0933915 0.32790527   3.334474 8.546100e-04
## treatment1su_ha_fin   1.3007122 0.30154908   4.313434 1.607378e-05
##                          Estimate Std. Error      z value     Pr(>|z|)
## (Intercept)          -0.920904011 0.89605136  -1.02773574 3.040741e-01
## as.numeric(cost)     -0.591132899 0.03854852 -15.33477353 4.478319e-53
## treatment1su_ha_neu   0.623928664 0.29792766   2.09422875 3.623961e-02
## treatment1sh_sev_fin  0.967391584 0.28546960   3.38877272 7.020618e-04
## treatment1sh_ha_fin   0.592629999 0.34154776   1.73513069 8.271766e-02
## treatment1su_sev_fin  1.023467645 0.35518680   2.88149118 3.957983e-03
## treatment1su_ha_fin   0.904591810 0.32714060   2.76514688 5.689717e-03
## female               -0.188819946 0.21098774  -0.89493325 3.708228e-01
## risk                 -0.182872832 0.06842854  -2.67246439 7.529637e-03
## age                   0.028804008 0.01025041   2.81003380 4.953630e-03
## investment           -0.125623362 0.21025849  -0.59747105 5.501929e-01
## pref1_1               0.134641799 0.08064849   1.66948933 9.502044e-02
## pref1_2              -0.005534019 0.08055232  -0.06870092 9.452277e-01
## pref1_3               0.050219376 0.06728007   0.74642279 4.554121e-01
## pref1_4               0.271611016 0.07025404   3.86612663 1.105775e-04
## pref2_1               0.093183512 0.10150612   0.91800883 3.586142e-01
## pref2_2              -0.170404697 0.07346853  -2.31942438 2.037204e-02
## pref2_3              -0.126314495 0.06391440  -1.97630723 4.811999e-02
## order                -0.052048717 0.17952656  -0.28992210 7.718758e-01
## 
## Logistic regression with standard errors clustered at the subject-level
## =============================================================
##                      Dependent variable: Prob(Honest report) 
##                      ----------------------------------------
##                                      choice1                 
##                              (1)                  (2)        
## -------------------------------------------------------------
## as.numeric(cost)           0.581***            0.554***      
##                            (0.035)              (0.039)      
##                                                              
## treatment1su_ha_neu        2.198***            1.866***      
##                            (0.282)              (0.298)      
##                                                              
## treatment1sh_sev_fin       2.979***            2.631***      
##                            (0.278)              (0.285)      
##                                                              
## treatment1sh_ha_fin        2.536***            1.809***      
##                            (0.317)              (0.342)      
##                                                              
## treatment1su_sev_fin       2.984***            2.783***      
##                            (0.328)              (0.355)      
##                                                              
## treatment1su_ha_fin        3.672***            2.471***      
##                            (0.302)              (0.327)      
##                                                              
## female                                         0.828***      
##                                                 (0.211)      
##                                                              
## risk                                           0.833***      
##                                                 (0.068)      
##                                                              
## age                                            1.029***      
##                                                 (0.010)      
##                                                              
## investment                                     0.882***      
##                                                 (0.210)      
##                                                              
## pref1_1                                        1.144***      
##                                                 (0.081)      
##                                                              
## pref1_2                                        0.994***      
##                                                 (0.081)      
##                                                              
## pref1_3                                        1.052***      
##                                                 (0.067)      
##                                                              
## pref1_4                                        1.312***      
##                                                 (0.070)      
##                                                              
## pref2_1                                        1.098***      
##                                                 (0.102)      
##                                                              
## pref2_2                                        0.843***      
##                                                 (0.073)      
##                                                              
## pref2_3                                        0.881***      
##                                                 (0.064)      
##                                                              
## order                                          0.949***      
##                                                 (0.180)      
##                                                              
## Constant                   2.138***              0.398       
##                            (0.212)              (0.896)      
##                                                              
## -------------------------------------------------------------
## Observations                2,075                2,075       
## Log Likelihood            -1,223.543          -1,140.210     
## Akaike Inf. Crit.         2,461.087            2,318.419     
## =============================================================
## Note:                             *p<0.1; **p<0.05; ***p<0.01
```

## Figure 3

Perceived severity of a lie's consequences and the influence of
reputational concerns on dishonest behavior.


``` r
tt_pf$treatment1 <- factor(tt_pf$treatment,
                              levels = rev(c('su_ha_abs',
                                             'su_ha_neu',
                                             'sh_sev_fin',
                                             'sh_ha_fin',
                                             'su_sev_fin',
                                             'su_ha_fin')))

tt_pf %>% 
  group_by(treatment1) %>% 
  summarise(Severity = mean(severity),
            Severitymax = CI(severity)[1],
            Severitymin = CI(severity)[3]) %>%
  mutate(severitytreat = ifelse(grepl("sev", treatment1), 
                                "severe", "harmless"),
         financialtreat = factor(ifelse(grepl("fin", treatment1), 1, 0))) %>% 
  ggplot(aes(x = treatment1, 
             y = Severity, 
             ymax = Severitymax,
             ymin = Severitymin,
             color = severitytreat,
             shape = financialtreat)) + 
  geom_errorbar(width=.2, lwd = 1) + 
  geom_point(lwd = 2.7) + 
  coord_flip() +   
  theme_bw(base_size = 18) + 
  theme(legend.position="bottom",
        legend.title = element_blank(),
        legend.background = element_blank(),
        legend.margin = margin(t = 0),
        legend.box.margin = margin(t = 0),
        legend.box.spacing = unit(0.3, "cm"),
        axis.title.y = element_blank(),
        panel.grid.minor.y = element_blank()) +
  scale_x_discrete(labels = rev(c(expression(ABS),
                                  expression(NEU),
                                  expression(FIN),
                                  expression(FIN[HA]^MANY),
                                  expression(FIN[SEV]^ONE),
                                  expression(FIN[HA]^ONE)))) + 
  scale_color_manual(values=viridis(n = 6)[c(1,5)]) + 
  scale_shape_manual(values = c(15, 5),
                     labels = c("non-financial", "financial")) + 
  scale_y_continuous(limits = c(1, 7),
                     breaks = seq(1, 7, 1)) +  
  ylab("Perceived severity of consequences") + 
  labs(title = "Perceived severity of consequences")
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-34-1.pdf)<!-- --> 

``` r
ggsave("../git_latex/graphs/Severity.pdf", width=20, height=15, units="cm")

tt_pf %>% 
  group_by(treatment1) %>% 
  summarise(Reputation = mean(reputation),
            Reputationmax = CI(reputation)[1],
            Reputationmin = CI(reputation)[3]) %>%
  mutate(financialtreat = factor(ifelse(grepl("fin", treatment1), 1, 0))) %>% 
  ggplot(aes(x = treatment1, 
             y = Reputation, 
             ymax = Reputationmax,
             ymin = Reputationmin,
             shape = financialtreat)) + 
  geom_errorbar(width=.2, lwd = 1, color = viridis(n = 6)[3]) + 
  geom_point(lwd = 2.7) + 
  coord_flip() +  
  theme_bw(base_size = 18) + 
  theme(legend.position="bottom",
        legend.title = element_blank(),
        legend.background = element_blank(),
        legend.margin = margin(t = 0),
        legend.box.margin = margin(t = 0),
        legend.box.spacing = unit(0.3, "cm"),
        axis.title.y = element_blank(),
        panel.grid.minor.y = element_blank()) +
  scale_x_discrete(labels = rev(c(expression(ABS),
                                  expression(NEU),
                                  expression(FIN),
                                  expression(FIN[HA]^MANY),
                                  expression(FIN[SEV]^ONE),
                                  expression(FIN[HA]^ONE)))) + 
  scale_shape_manual(values = c(15, 5),
                     labels = c("non-financial", "financial")) + 
  scale_y_continuous(limits = c(1, 7),
                     breaks = seq(1, 7, 1)) +  
  ylab("Influence of reputational concerns") +
  labs(title = "Reputational concerns")
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-34-2.pdf)<!-- --> 

``` r
ggsave("../git_latex/graphs/ReputationalConcerns.pdf", width=20, height=15, units="cm")
```

## Figure B1

Beliefs about the percentage of dishonest reports as a function of the
economic costs of honesty.


``` r
tt_stud_reshaped$treatment1 <- factor(tt_stud_reshaped$treatment, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))
options(repr.plot.width  = 8,
        repr.plot.height = 6)
ggplot(tt_stud_reshaped %>%
         filter(question=="belief") %>%
         mutate(cost = as.numeric(cost) * (-1) + 5) %>%                  
         group_by(cost, treatment1) %>%
         summarise(belief=100 - mean(choice)),
       aes(x=cost, y=belief, group=treatment1)) + 
  geom_line(aes(color=treatment1, linetype=treatment1), size=2) + 
  geom_point() + 
  labs(x="Economic cost of honesty",
       y="Percentage of honest reports") + 
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom",
        legend.key.width = unit(3, "line"),
        legend.title = element_blank(),
        panel.grid.minor.x = element_blank()) + 
  scale_linetype_discrete(guide = 'legend', name="Treatment",
                          labels = c(expression(FIN),
                                     expression(NEU), 
                                     expression(ABS))) + 
  scale_color_manual(guide = 'legend', name="Treatment", values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) + 
  ylim(0, 100) + 
  labs(title = "STUD")  
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by cost and treatment1.
## i Output is grouped by cost.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(cost, treatment1))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-35-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/BeliefsPercLies_STUD.pdf", width=20, height=15, units="cm")
```


``` r
tt_before_reshaped$treatment1 <- factor(tt_before_reshaped$treatment, levels = c('sh_sev_fin', 'sh_ha_fin', 'su_ha_neu',
                                                                         'su_sev_fin', 'su_ha_abs', 'su_ha_fin'))
tt_pf_reshaped$treatment1 <- factor(tt_pf_reshaped$treatment, levels = c('sh_sev_fin', 'sh_ha_fin', 'su_ha_neu',
                                                                         'su_sev_fin', 'su_ha_abs', 'su_ha_fin'))
options(repr.plot.width  = 8,
        repr.plot.height = 6)
ggplot(rbind(tt_before_reshaped, tt_pf_reshaped) %>%
         filter(question=="belief",
                treatment=="su_ha_neu"|treatment=="su_ha_abs"|treatment=="sh_sev_fin") %>%
         mutate(cost = as.numeric(cost) * (-1) + 5) %>%                  
         group_by(cost, context) %>%
         summarise(belief=100 - mean(choice)),
       aes(x=cost, y=belief, group=context)) + 
  geom_line(aes(color=context, linetype=context), size=2) + 
  geom_point() + 
  labs(x="Economic cost of honesty",
       y="Percentage of honest reports") + 
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom",
        legend.key.width = unit(3, "line"),
        legend.title = element_blank(),
        panel.grid.minor.x = element_blank()) + 
  scale_linetype_discrete(guide = 'legend', name="Treatment",
                          labels = c(expression(FIN),
                                     expression(NEU),
                                     expression(ABS))) + 
  scale_color_manual(guide = 'legend', name="Treatment", values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) + 
  ylim(0, 100) + 
  labs(title = "PROF") 
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by cost and context.
## i Output is grouped by cost.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(cost, context))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-36-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/BeliefsPercLies_PROF.pdf", width=20, height=15, units="cm")
```

Correlation own lying behavior/beliefs


``` r
cor.test(tt$lies, tt$beliefs)
```

```
## 
## 	Pearson's product-moment correlation
## 
## data:  tt$lies and tt$beliefs
## t = 17.388, df = 579, p-value < 2.2e-16
## alternative hypothesis: true correlation is not equal to 0
## 95 percent confidence interval:
##  0.5295813 0.6367038
## sample estimates:
##       cor 
## 0.5856944
```

## Figure 5

Percentage of dishonest reports as a function of expectations by a
separate groups of subjects


``` r
normsbeliefs <- merge %>%
  filter(prof1.tt == 1) %>% 
  group_by(prof.norms, treatment1, cost) %>%
  summarise(norm = mean(norm, na.rm=TRUE), 
            normf = mean(norms_false, na.rm=TRUE), 
            normt = mean(norms_true, na.rm=TRUE), 
            choice = mean(choice, na.rm=TRUE), 
            belief = mean(norms_belief, na.rm=TRUE), n())
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof.norms, treatment1, and cost.
## i Output is grouped by prof.norms and treatment1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof.norms, treatment1, cost))` for per-operation
##   grouping (`?dplyr::dplyr_by`) instead.
```


``` r
normsbeliefs$treatment1 <- factor(normsbeliefs$treatment1, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))

ggplot(normsbeliefs %>% filter(prof.norms==1), aes(x = 1 - belief, y = 1 - choice)) +
  geom_smooth(method = lm, color="grey40") +  
  geom_point(aes(color = treatment1, shape = treatment1), size = 4.2) +
  labs(x="Expected percentage of honest reports \n in the norm-elicitation experiment",
       y="Percentage of honest reports \n in the main experiment") +   
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom") +   
  scale_color_manual(guide = "legend", name="", 
                     values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) + 
  scale_shape_manual(guide = "legend", name="",
                     values = c(19, 17, 15),
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) +   
  scale_y_continuous(limits = c(0, 1), breaks=seq(0, 1, 0.25)) + 
  xlim(0, 1) + 
  labs(title = bquote("PROF")) 
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-39-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/BeliefsPercLiesExpIExpII_PROF.pdf", width=20, height=15, units="cm")
```


``` r
1 - normsbeliefs %>% filter(prof.norms==1) %>% .$belief %>% max(na.rm=TRUE)
```

```
## [1] 0.426875
```

``` r
normsbeliefs %>% filter(prof.norms==1) %>% filter(1 - choice < 0.426875) %>% .$choice %>% length()
```

```
## [1] 5
```


``` r
normsbeliefsstudprof <- merge %>%
  filter(prof.norms==2) %>%
  group_by(prof.norms, treatment1, cost) %>%
  summarise(norm = mean(norm), choice = mean(choice), beliefstudprof = mean(norms_belief)) %>%
  ungroup %>%
  dplyr::select(-starts_with("prof")) %>% 
  na.omit()
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof.norms, treatment1, and cost.
## i Output is grouped by prof.norms and treatment1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof.norms, treatment1, cost))` for per-operation
##   grouping (`?dplyr::dplyr_by`) instead.
```

``` r
normsbeliefs1 <- full_join(normsbeliefs,
                           normsbeliefsstudprof,
                           by = c("treatment1", "cost"),
                           suffix = c(".norms", ".studprof")) %>%
  na.omit()
```


``` r
normsbeliefs1$treatment1 <- factor(normsbeliefs1$treatment1, levels = c('sh_sev_fin', 'su_ha_neu', 'su_ha_abs'))

ggplot(normsbeliefs1 %>% filter(prof.norms==1), aes(x = 1 - beliefstudprof, y = 1 - choice.norms)) +
  geom_smooth(method = lm, color="grey40") +    
  geom_point(aes(color = treatment1, shape = treatment1), size = 4.2) + 
  labs(x="Expected percentage of honest reports \n in the norm-elicitation experiment",
       y="Percentage of honest reports \n in the main experiment") +   
  theme_bw() +  
  theme(text = element_text(size = 20)) +   
  theme(legend.position="bottom") +   
  scale_color_manual(guide = "legend", name="", 
                     values=viridis(n = 6)[c(1, 3, 5)],
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) + 
  scale_shape_manual(guide = "legend", name="",
                     values = c(19, 17, 15),
                     labels = c(expression(FIN), 
                                expression(NEU), 
                                expression(ABS))) +   
  scale_y_continuous(limits = c(0, 1), breaks=seq(0, 1, 0.25)) + 
  xlim(0, 1) + 
  labs(title = bquote("STUD"^"PROF"))
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-42-1.pdf)<!-- --> 

``` r
ggsave("../git_data/graphs/BeliefsPercLiesExpIExpII_STUDPROF.pdf", width=20, height=15, units="cm")
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

## Table B8

Decision-situation-level ordinary least squares estimation of the
percentage of dishonest reports


``` r
regbeliefsexpIexpII_stud <- lm(choice ~ belief, data = normsbeliefs %>% filter(prof.norms==0))
regbeliefsexpIexpII_prof <- lm(choice ~ belief, data = normsbeliefs %>% filter(prof.norms==1))
regbeliefsexpIexpII_studprof <- lm(choice.norms ~ beliefstudprof, data = normsbeliefs1 %>% filter(prof.norms==1))

stargazer(regbeliefsexpIexpII_prof, regbeliefsexpIexpII_studprof, regbeliefsexpIexpII_stud, type = "text", digits=3)
```

```
## 
## ==============================================================
##                                     Dependent variable:       
##                               --------------------------------
##                                choice   choice.norms  choice  
##                                  (1)        (2)         (3)   
## --------------------------------------------------------------
## belief                        1.346***               1.755*** 
##                                (0.144)                (0.337) 
##                                                               
## beliefstudprof                            1.434***            
##                                           (0.415)             
##                                                               
## Constant                       -0.011      -0.315    -0.426** 
##                                (0.053)    (0.222)     (0.169) 
##                                                               
## --------------------------------------------------------------
## Observations                     15          15         15    
## R2                              0.871      0.479       0.676  
## Adjusted R2                     0.861      0.438       0.651  
## Residual Std. Error (df = 13)   0.086      0.172       0.136  
## F Statistic (df = 1; 13)      87.705***  11.933***   27.092***
## ==============================================================
## Note:                              *p<0.1; **p<0.05; ***p<0.01
```


``` r
linearHypothesis(regbeliefsexpIexpII_prof, "belief = 1")
```

```
## 
## Linear hypothesis test:
## belief = 1
## 
## Model 1: restricted model
## Model 2: choice ~ belief
## 
##   Res.Df      RSS Df Sum of Sq      F  Pr(>F)  
## 1     14 0.138092                              
## 2     13 0.095514  1  0.042578 5.7951 0.03165 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

## Subject-group differences in social norms


``` r
# Wilcoxon rank sum test: STUD vs. PROF for ABSTRACT
wilcox.test(norms_false ~ prof, data = norms %>% filter(prof!=2, context=="abstract"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by prof
## W = 302, p-value = 7.918e-05
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: STUD vs. PROF for NEUTRAL
wilcox.test(norms_false ~ prof, data = norms %>% filter(prof!=2, context=="neutral"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by prof
## W = 307, p-value = 0.04171
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: STUD vs. PROF for FINANCIAL
wilcox.test(norms_false ~ prof, data = norms %>% filter(prof!=2, context=="financial"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by prof
## W = 230.5, p-value = 6.509e-05
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: neutral vs. financial
wilcox.test(norms_true ~ prof, data = norms %>% filter(prof!=2, context=="abstract"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_true by prof
## W = 120, p-value = 0.09723
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: abstract vs. financial
wilcox.test(norms_true ~ prof, data = norms %>% filter(prof!=2, context=="neutral"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_true by prof
## W = 268.5, p-value = 0.2505
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: abstract vs. neutral
wilcox.test(norms_true ~ prof, data = norms %>% filter(prof!=2, context=="financial"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_true by prof
## W = 71.5, p-value = 0.0257
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Kruskal-Wallis test:
kruskal.test(norms_true ~ prof, data = norms)
```

```
## 
## 	Kruskal-Wallis rank sum test
## 
## data:  norms_true by prof
## Kruskal-Wallis chi-squared = 1.326, df = 2, p-value = 0.5153
```

## Treatment differences in social norms


``` r
# Wilcoxon rank sum test: abstract vs. neutral
wilcox.test(norms_false ~ context, data = norms %>% filter(prof==1, context!="financial"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by context
## W = 98.5, p-value = 0.2663
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: abstract vs. financial
wilcox.test(norms_false ~ context, data = norms %>% filter(prof==1, context!="neutral"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by context
## W = 155.5, p-value = 0.01935
## alternative hypothesis: true location shift is not equal to 0
```


``` r
# Wilcoxon rank sum test: neutral vs. financial
wilcox.test(norms_false ~ context, data = norms %>% filter(prof==1, context!="abstract"))
```

```
## 
## 	Wilcoxon rank sum exact test
## 
## data:  norms_false by context
## W = 32.5, p-value = 0.0008913
## alternative hypothesis: true location shift is not equal to 0
```

## Variation across economic costs of honesty

Correlation between economic costs of honesty and social appropriateness
of an *honest* report:


``` r
cor.test(reshaped_norms$cost, reshaped_norms$norms_true)
```

```
## 
## 	Pearson's product-moment correlation
## 
## data:  reshaped_norms$cost and reshaped_norms$norms_true
## t = 1.2357, df = 913, p-value = 0.2169
## alternative hypothesis: true correlation is not equal to 0
## 95 percent confidence interval:
##  -0.02401338  0.10539096
## sample estimates:
##        cor 
## 0.04086013
```

Correlation between economic costs of honesty and social appropriateness
of a *dishonest* report:


``` r
cor.test(reshaped_norms$cost, reshaped_norms$norms_false)
```

```
## 
## 	Pearson's product-moment correlation
## 
## data:  reshaped_norms$cost and reshaped_norms$norms_false
## t = -0.37549, df = 913, p-value = 0.7074
## alternative hypothesis: true correlation is not equal to 0
## 95 percent confidence interval:
##  -0.07717368  0.05242623
## sample estimates:
##         cor 
## -0.01242591
```

## Figure 4


``` r
gathered <- norms %>%
  gather(key = "truefalse", value = "norms", c(norms_true, norms_false))
gathered$context1 <- factor(gathered$context, levels = c('abstract', 'neutral', 'financial'))
```


``` r
gathered$treatment1 <- factor(gathered$context, 
                              levels = c('financial', 'neutral', 'abstract'),
                              labels = c(expression(FIN[SEV]^MANY),
                                         expression(NEU[HA]^ONE),
                                         expression(ABS[HA]^ONE)))

ggplot(data = gathered %>%
         ungroup %>%
         mutate(prof1 = ifelse(prof==2, 0.5, prof),
                prof1 = factor(prof1,
                               levels = c(0, 0.5, 1),
                               labels = c("STUD", 
                                          bquote("STUD"^"PROF"), 
                                          "PROF"))) %>%
         filter(truefalse == "norms_false") %>% 
         group_by(prof1, treatment1) %>%
         summarise(normsmax = CI(norms)[1],
                   normsmin = CI(norms)[3],
                   norms = mean(norms)),
       aes(x = factor(treatment1), y = norms,
           ymin = normsmin, ymax = normsmax,
           color=factor(treatment1), shape=factor(treatment1))) +
  geom_errorbar(width=.2, lwd = 1) +   
  geom_point(lwd = 2.7) + 
  facet_wrap( ~ prof1, labeller = label_parsed) + 
  geom_hline(yintercept = 0) + 
  labs(x="",
       y="Social approriateness \n of a dishonest report") +   
  theme_bw() + 
  theme(text = element_text(size = 16)) +     
  theme(legend.position="bottom") +
  theme(axis.text.x=element_blank()) + 
  theme(panel.spacing = unit(0, "lines")) + 
  scale_x_discrete(breaks = NULL) + 
  scale_y_continuous(breaks = scales::pretty_breaks(n = 6), limits = c(-1, 0.18)) + 
  scale_color_manual(guide="legend",
                     name="",
                     values=viridis(n = 6)[c(1,3,5)],
                     labels = c(expression(FIN),
                                         expression(NEU),
                                         expression(ABS))) + 
  scale_shape_discrete(guide="legend",
                       name="",
                       labels = c(expression(FIN),
                                         expression(NEU),
                                         expression(ABS)))
```

```
## `summarise()` has regrouped the output.
## i Summaries were computed grouped by prof1 and treatment1.
## i Output is grouped by prof1.
## i Use `summarise(.groups = "drop_last")` to silence this message.
## i Use `summarise(.by = c(prof1, treatment1))` for per-operation grouping
##   (`?dplyr::dplyr_by`) instead.
```

```
## Warning in geom_point(lwd = 2.7): Ignoring unknown parameters: `linewidth`
```

![](Huber2020_reproduced_files/figure-latex/unnamed-chunk-58-1.pdf)<!-- --> 

``` r
ggsave("../git_latex/graphs/Norms_lineplot.pdf", width=25, height=15, units="cm")
```

# Variable descriptions

| Variable | Description |
|----|----|
| `subject` | Subject ID |
| `payoff` | Payout from the experiment |
| `session` | Experimental session ID |
| `context` | Treatment (context, framed instructions): `abstract`, `neutral`, or `financial` |
| `order` | Ascending or decreasing order of decisions (randomly drawn for each subject) |
| `choice1` | Choice in decision 1: `0` (honest report) or `1` (dishonest report) |
| `choice2` | Choice in decision 2: `0` (honest report) or `1` (dishonest report) |
| `choice3` | Choice in decision 3: `0` (honest report) or `1` (dishonest report) |
| `choice4` | Choice in decision 4: `0` (honest report) or `1` (dishonest report) |
| `choice5` | Choice in decision 5: `0` (honest report) or `1` (dishonest report) |
| `belief1` | Expected percentage of dishonest reports in decision 1 |
| `belief2` | Expected percentage of dishonest reports in decision 2 |
| `belief3` | Expected percentage of dishonest reports in decision 3 |
| `belief4` | Expected percentage of dishonest reports in decision 4 |
| `belief5` | Expected percentage of dishonest reports in decision 5 |
| `risk` | Risk preferences elicited with the general risk question, `1` (...) to `7` (...) |
| `pref1_1` | Patience (Falk et al., 2018): `1` (completely unwilling to do so) to `7` (very willing to do so) |
| `pref1_2` | Negative Reciprocity 1 (Falk et al., 2018): `1` (completely unwilling to do so) to `7` (very willing to do so) |
| `pref1_3` | Negative Reciprocity 2 (Falk et al., 2018): `1` (completely unwilling to do so) to `7` (very willing to do so) |
| `pref1_4` | Altruism (Falk et al., 2018): `1` (completely unwilling to do so) to `7` (very willing to do so) |
| `pref2_1` | Positive Reciprocity (Falk et al., 2018): `1` (does not describe me at all) to `7` (describes me perfectly) |
| `pref2_2` | Negative Reciprocity 3 (Falk et al., 2018): `1` (does not describe me at all) to `7` (describes me perfectly) |
| `pref2_3` | Trust (Falk et al., 2018): `1` (does not describe me at all) to `7` (describes me perfectly) |
| `age` | Age |
| `female` | Gender: `0` (male) or `1` (female) |
| `education` | Education: `0` (Compulsory school), `1` (Apprenticeship), `2` (Technical college), `3` (High school), `4` (University), or `-1` (Prefer not to say) |
| `job` | Job (only PROF): `0` (Portfolio Manager), `1` (Research Analyst), `2` (Consultant), `3` (Financial Advisor), `4` (Chief-Level Executive), `5` (Trader), `6` (Fund Manager), `7` (Investment Managent), or `8` (Other) |
| `investment` | Investment in financial products in the last 5 years: yes (`1`) or no (`0`) |
| `whichinvestment` | If `investment = 1`, which financial product |
| `finnews` | Check financial news: `4` (Daily), `3` (Several times a week), `2` (Once a week), `1` (Less than once a week), or `0` (Never) |
| `tt` | Truth-telling task (`1`) or norm-elicitation task (`0`) |
| `word1` | Answer to word scarambling 1 |
| `word2` | Answer to word scarambling 2 |
| `word3` | Answer to word scarambling 3 |
| `word4` | Answer to word scarambling 4 |
| `word5` | Answer to word scarambling 5 |
| `word6` | Answer to word scarambling 6 |
| `word1f` | Financial word in word scrambing 1: yes (`1`) or no (`0`) |
| `word3f` | Financial word in word scrambing 3: yes (`1`) or no (`0`) |
| `word4f` | Financial word in word scrambing 4: yes (`1`) or no (`0`) |
| `word6f` | Financial word in word scrambing 6: yes (`1`) or no (`0`) |
| `wordsf` | Sum of financial words in word scramblings 1, 3, 4, and 6 |
| `lies` | Number of dishonest reports in decisions 1 through 5 |
| `beliefs` | Expected number of dishonest reports in decisions 1 through 5 |
| `prof` | Subject group: `0` (STUD), `1` (PROF), or `2` (STUDPROF) |
| `norms_true1` | Social appropriateness assessment of an honest report in decision 1 |
| `norms_false1` | Social appropriateness assessment of a dishonest report in decision 1 |
| `norms_true2` | Social appropriateness assessment of an honest report in decision 2 |
| `norms_false2` | Social appropriateness assessment of a dishonest report in decision 2 |
| `norms_true3` | Social appropriateness assessment of an honest report in decision 3 |
| `norms_false3` | Social appropriateness assessment of a dishonest report in decision 3 |
| `norms_true4` | Social appropriateness assessment of an honest report in decision 4 |
| `norms_false5` | Social appropriateness assessment of a dishonest report in decision 4 |
| `norms_true5` | Social appropriateness assessment of an honest report in decision 5 |
| `norms_false5` | Social appropriateness assessment of a dishonest report in decision 5 |
| `norms_true` | Average social appropriateness assessment of an honest report |
| `norms_false` | Average social appropriateness assessment of a dishonest report |
