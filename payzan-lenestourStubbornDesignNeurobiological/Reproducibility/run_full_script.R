#### Set up the environment--------
# Get the path of the current R script, if you don't have Rstudio, then manually input the path of this script
script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Set the working directory to the "Data" folder
setwd(file.path(script_path, "Data"))
suppl_code_path=file.path(script_path, "Supplementary Codes")

#Please install the below R Packagaes before running the code
suppressMessages({
  library(tidyverse)
  library(moments)
  library(EnvStats)
  library(blme)
  library(knitr)
  library(MuMIn)
  library(performance)
  library(ggsignif)
  library(psych)
  library(lsr)
  library(usdm)
  library(truncnorm)
  library(DFBA)
  library(effectsize)
  library(rstatix)
  library(coin)
})

# SE function
se <- function (x) {
  se = sd(x, na.rm = TRUE)/sqrt(length(x))
  return(se)
}

#### LOAD DATA ####

# Load data and run feature engineering with theta set to 1
data <- read.csv("aggregated data_all participants.csv")

theta_fun <- function() {
  return(1)
}

#Process the data to add features for regressions
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "feature_engineering.R"))
#Option 2: direclty load the processed data by us, which is adopted here
data <- read.csv("data_reduced.csv")

#### DESCRIPTIVE STATS AND PARTICIPANTS DEMOGRAPHICS ####
# Basic descriptive statistics and some tables

# Number of participants
n <- length(unique(data$id))


# Age distribution
age_by_n_control <- data %>%
  filter(treatment == "control") %>%
  group_by(id) %>%
  summarize(age = mean(age)) %>%
  ungroup %>%
  filter(age != 0)

age_by_n_test <- data %>%
  filter(treatment == "test") %>%
  group_by(id) %>%
  summarize(age = mean(age)) %>%
  ungroup %>%
  filter(age != 0)

# Gender distribution
gender_by_n_control <- data %>%
  filter(treatment == "control") %>%
  group_by(id) %>%
  summarize(gender = mean(gender)) %>%
  ungroup

gender_by_n_test <- data %>%
  filter(treatment == "test") %>%
  group_by(id) %>%
  summarize(gender = mean(gender)) %>%
  ungroup

# Major distribution
major_by_n_control <- data %>%
  filter(treatment == "control") %>%
  group_by(id) %>%
  summarize(major = mean(major)) %>%
  ungroup

major_by_n_test <- data %>%
  filter(treatment == "test") %>%
  group_by(id) %>%
  summarize(major = mean(major)) %>%
  ungroup


#TABLE C.I. in Appendix C: SUMMARY OF PARTICIPANT DEMOGRAPHICS BY TREATMENT GROUP
{
#Control, gender
sum(gender_by_n_control$gender==1)#Female
sum(gender_by_n_control$gender==2)#Male
sum(gender_by_n_control$gender==3)#Other
#Test, gender
sum(gender_by_n_test$gender==1)#Female
sum(gender_by_n_test$gender==2)#Male
sum(gender_by_n_test$gender==3)#Other
#Control, age
sum(age_by_n_control$age<20)#<20
sum(age_by_n_control$age>=20 & age_by_n_control$age<=25)#20-25
sum(age_by_n_control$age>25)#>25
#Test, age
sum(age_by_n_test$age<20)#<20
sum(age_by_n_test$age>=20 & age_by_n_test$age<=25)#20-25
sum(age_by_n_test$age>25)#>25
#Control, discipline
sum(major_by_n_control$major ==1 )#STEM
sum(major_by_n_control$major == 2)#Business
sum(major_by_n_control$major >2)#Other
#Test, discipline
sum(major_by_n_test$major ==1 )#STEM
sum(major_by_n_test$major == 2)#Business
sum(major_by_n_test$major >2)#Other
}



#### Table 1 ####
{
  betting_stats_blue_c <- data %>%
    filter(block_type == "S" & treatment == 'control') %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_blue_c_sub <- betting_stats_blue_c['betting_rate',
                                                   c('mean', 'median', 'sd',
                                                     'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_blue_c_sub) <- 'Control'

  betting_stats_blue_t <- data %>%
    filter(block_type == "S" & treatment == 'test') %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_blue_t_sub <- betting_stats_blue_t['betting_rate',
                                                   c('mean', 'median', 'sd',
                                                     'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_blue_t_sub) <- 'Test'

  betting_stats_blue <- data %>%
    filter(block_type == "S") %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_blue_sub <- betting_stats_blue['betting_rate',
                                               c('mean', 'median', 'sd',
                                                 'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_blue_sub) <- 'Total'

  # Betting rate in yellow
  betting_stats_yellow_c <- data %>%
    filter(block_type == "C" & treatment == 'control') %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_yellow_c_sub <- betting_stats_yellow_c['betting_rate',
                                                       c('mean', 'median', 'sd',
                                                         'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_yellow_c_sub) <- 'Control'

  betting_stats_yellow_t <- data %>%
    filter(block_type == "C" & treatment == 'test') %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_yellow_t_sub <- betting_stats_yellow_t['betting_rate',
                                                       c('mean', 'median', 'sd',
                                                         'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_yellow_t_sub) <- 'Test'

  betting_stats_yellow <- data %>%
    filter(block_type == "C") %>%
    group_by(id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup %>%
    psych::describe()

  betting_stats_yellow_sub <- betting_stats_yellow['betting_rate',
                                                   c('mean', 'median', 'sd',
                                                     'min', 'max', 'skew')] %>%
    round(3) %>%
    t
  colnames(betting_stats_yellow_sub) <- 'Total'

  table_1 <- betting_stats_blue_c_sub %>%
    cbind(betting_stats_blue_t_sub, betting_stats_blue_sub, betting_stats_yellow_c_sub,
          betting_stats_yellow_t_sub, betting_stats_yellow_sub) %>%
    as.data.frame()

  cols_treat <- colnames(table_1)

  table_1 <- cols_treat %>%
    rbind(table_1)

  colnames(table_1) <- c('', 'Blue', '', '', 'Yellow', '')
  rownames(table_1) <- c('', 'Mean', 'Median', 'SD', 'Min', 'Max', 'Skew')

  cat("TABLE I\n PARTICIPANT BETTING RATES BY SESSION COLOR AND TREATMENT. \n")
  print(table_1)
}
#### Figure 3 ####
{
  #### Distribution plot ####

  data_dists <- data %>%
    group_by(id, treatment, block_type) %>%
    summarize(betting_rate = mean(choice, na.rm=TRUE)) %>%
    ungroup %>%
    mutate(block_type = factor(block_type, levels = c('S', 'C'),
                               labels = c('S', 'C')))

  dev.new(width=8, height=8)
  ggplot(data_dists, aes(x = treatment, y = betting_rate, fill = block_type)) +
    geom_boxplot() +
    scale_x_discrete(name = '',
                     breaks = c('control', 'test'),
                     labels = c('Control', 'Test')) +
    scale_y_continuous(name = 'Betting rate') +
    scale_fill_manual(name = 'Session color',
                      breaks = c('C', 'S'),
                      labels = c('Yellow', 'Blue'),
                      values = c('#ffd700', '#0057b7')) +
    theme_minimal() +
    theme(axis.title = element_text(size = 14),
          axis.text = element_text(size = 12),
          legend.title = element_text(size = 14),
          legend.text = element_text(size = 12),
          strip.text = element_text(size = 14),
          axis.title.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0))) +
    facet_wrap('block_type', nrow = 1, scales = 'free_y') +
    theme(strip.text.x = element_blank(),
          panel.spacing = unit(15, "pt"))

  #ggsave('./plots/betting_rate_distribution.png', width = 7, height = 5)

}
#### Figure 4 and Tests results ####
#Uncertainty Effect:
{
  #Paired one-tailed t-test, participant level
  # Betting rate in low/high uncertainty
  data_6 <- data %>%
    mutate(uncertainty = factor(aaron_mood, levels = c("Low", "High"),
                                labels = c("Low", "High"))) %>%
    filter(block_type == "C") %>%
    group_by(id, uncertainty) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup

  # Check skew and normality assumption
  skew_6_bf <- round(skewness(sqrt(data_6$betting_rate)), 3)
  shap_6_bf <- shapiro.test(data_6$betting_rate)


  # Box-Cox transform
  out <- boxcox(data_6$betting_rate + 1, lambda = seq(-25, 25, by = 0.25))
  bc_6_lambda <- out$lambda[which.max(out$objective)]
  bc_6_lambda=-13.5
  data_6$betting_rate_bc <- boxcoxTransform(data_6$betting_rate + 1,
                                            lambda = bc_6_lambda)

  skew_6_af <- round(skewness(sqrt(data_6$betting_rate_bc)), 3)
  shap_6_af <- shapiro.test(data_6$betting_rate_bc)


  # Run test
  t_test_6 <- t.test(
    x = data_6$betting_rate_bc[data_6$uncertainty == "High"],
    y = data_6$betting_rate_bc[data_6$uncertainty == "Low"],
    paired = TRUE,
    alternative = 'less'
  )
  print(t_test_6)
  print("effect size is:")
  print(cohensD(data_6$betting_rate_bc[data_6$uncertainty == 'High'], data_6$betting_rate_bc[data_6$uncertainty == 'Low'], method="paired"))
  # Non-parametric
  wilcox_6 <- wilcox.test(x = data_6$betting_rate[data_6$uncertainty == "High"],
                          y = data_6$betting_rate[data_6$uncertainty == "Low"],
                          alternative = 'g',
                          paired = TRUE)
  print(wilcox_6)
  print("effect size is:")
  print(effectsize(wilcox_6))


  data_plot_u <- data %>%
    filter(block_type == "C") %>%
    group_by(aaron_mood, id) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup

  out <- boxcox(data_plot_u$betting_rate + 1, lambda = seq(-25, 25, by = 0.25))
  bc_plot6_lambda <- out$lambda[which.max(out$objective)]

  data_plot_u$betting_rate_bc <- boxcoxTransform(data_plot_u$betting_rate + 1,
                                                 lambda = bc_plot6_lambda)

  # Plot test 6
  data_plot_u <- data_plot_u %>%
    group_by(aaron_mood) %>%
    summarize(se = se(betting_rate),
              betting_rate = mean(betting_rate)) %>%
    ungroup %>%
    mutate(aaron_mood = factor(aaron_mood, levels = c('Low', 'High'),
                               labels = c('Low', 'High')))

  # Test for uncertainty
  p_unc <- t_test_6$p.value
  p_unc <- if_else(p_unc < .001, '***',
                   if_else(p_unc < .01, '**',
                           if_else(p_unc < .05, '*', 'n.s.')))
  dev.new(width=8, height=10)
  ggplot(data_plot_u, aes(x = aaron_mood, y = betting_rate)) +
    geom_bar(stat='identity', position = position_dodge(.9), fill = '#ffd700',
             width = 0.6) +
    geom_errorbar(aes(ymin = betting_rate - se, ymax = betting_rate + se),
                  position = position_dodge(.9), width = .1) +
    scale_x_discrete(name = '', breaks = c('Low', 'High'),
                     labels = c('Low uncertainty', 'High uncertainty')) +
    scale_y_continuous(name = 'Betting rate') +
    theme_minimal() +
    theme(axis.title = element_text(size = 25),
          axis.text = element_text(size = 25),
          legend.title = element_text(size = 25),
          legend.text = element_text(size = 25),
          strip.text = element_text(size = 25)) +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank()) +
    geom_signif(comparisons = list(c('Low', 'High')),
                map_signif_level = TRUE,
                annotations = c(p_unc),
                margin_top = 0.1,
                size = .8,
                textsize = 10)+
    theme(axis.title.y = element_text(margin = margin(r = 20)))+
    theme(plot.margin = margin(t = 45))

  #ggsave('./plots/betting_rate_by_unc.png', width = 4, height = 7)
}

#Treatment Effect:
{
  # T-test C vs T in yellow
  data_7_2 <- data %>%
    filter(block_type == "C") %>%
    group_by(id, treatment) %>%
    summarize(betting_rate = mean(choice)) %>%
    ungroup

  out <- boxcox(data_7_2$betting_rate + 1, lambda = seq(-25, 25, by = 0.25))
  bc_72_lambda <- out$lambda[which.max(out$objective)]

  data_7_2$betting_rate_bc <- boxcoxTransform(data_7_2$betting_rate + 1,
                                              lambda = bc_72_lambda)

  t_test_7_2 <- t.test(data_7_2$betting_rate_bc[data_7_2$treatment == 'test'], data_7_2$betting_rate_bc[data_7_2$treatment == 'control'],alternative = "g")
  print(t_test_7_2)
  print("effect size is:")
  print(cohensD(data_7_2$betting_rate_bc[data_7_2$treatment == 'test'], data_7_2$betting_rate_bc[data_7_2$treatment == 'control']))
  # Non-parametric
  wilcox_7_2 <- wilcox.test(x = data_7_2$betting_rate[data_7_2$treatment == "test"],
                            y = data_7_2$betting_rate[data_7_2$treatment == "control"],
                            paired = FALSE,
                            alternative='g',
                            data = data_7_2)
  print(wilcox_7_2)
  print("effect size is:")
  print(effectsize(wilcox_7_2))

  # Plot test 7 (2)
  data_plot_t <- data_7_2 %>%
    group_by(treatment) %>%
    summarize(se = se(betting_rate),
              betting_rate = mean(betting_rate)) %>%
    ungroup %>%
    mutate(treatment = factor(treatment, levels = c('control', 'test'),
                              labels = c('Control', 'Test')))

  p_treat <- t_test_7_2$p.value
  p_treat <- if_else(p_treat < .001, '***',
                     if_else(p_treat < .01, '**',
                             if_else(p_treat < .05, '*', 'n.s.')))
  dev.new(width=8, height=10)
  ggplot(data_plot_t, aes(x = treatment, y = betting_rate)) +
    geom_bar(stat='identity', position = position_dodge(.9), fill = '#ffd700',
             width = 0.6) +
    geom_errorbar(aes(ymin = betting_rate - se, ymax = betting_rate + se),
                  position = position_dodge(.9), width = .1) +
    scale_x_discrete(name = '', breaks = c('Control', 'Test')) +
    scale_y_continuous(name = 'Betting rate') +
    theme_minimal() +
    theme(axis.title = element_text(size = 25),
          axis.text = element_text(size = 25),
          legend.title = element_text(size = 25),
          legend.text = element_text(size = 25),
          strip.text = element_text(size = 25)) +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank()) +
    geom_signif(comparisons = list(c('Control', 'Test')),
                map_signif_level = TRUE,
                annotations = c(p_treat),
                margin_top = 0.1,
                size = .8,
                textsize = 10)+
  theme(axis.title.y = element_text(margin = margin(r = 20)))+
    theme(plot.margin = margin(t = 45))
}

#### Mixed-Regressions ####
#Table 2 A and Table D. I
{
  # Logistic model to predict betting in any trial

  data_3 <- data %>%
    mutate(reward_value = factor(reward_value, levels = c("Low", "High"),
                                 labels = c("Low", "High")),
           uncertainty = factor(aaron_mood, levels = c("Low", "High"),
                                labels = c("Low", "High")),
           treatment = factor(treatment, levels = c("control", "test"),
                              labels = c("Control", "Test")),
           color = factor(block_type, levels = c("S", "C"),
                          labels = c("Blue", "Yellow")),
           age = scale(age),
           gender = factor(gender),
           major = factor(major),
           reaction_time = scale(reaction_time),
           sequence_number = scale(sequence_number),
           reward_exposure = scale(exposure_time))

  log_mod_3 <- bglmer(choice ~ reward_value + uncertainty +
                        treatment * color + previous_choice + reward_exposure +
                        age + gender + major + sequence_number + reaction_time +
                        (1 | id), fixef.prior = t, data = data_3,
                      family = binomial(link = "logit"))

  summary(log_mod_3)

  # Nakagawa R^2
  r2_nakagawa(log_mod_3)$R2_conditional

  # Number of obs
  summary(log_mod_3)$devcomp$dims[1]

  # Multicollinearity
  data_3_vif <- data_3[,c('reward_value', 'uncertainty', 'treatment',
                          'color', 'age', 'gender', 'major', 'reaction_time',
                          'sequence_number', 'previous_choice',
                          'reward_exposure')] %>%
    mutate(reward_value = as.numeric(reward_value),
           uncertainty = as.numeric(uncertainty),
           treatment = as.numeric(treatment),
           gender = as.numeric(gender),
           major = as.numeric(major),
           color = as.numeric(color))
  vif_mod_3_out <- usdm::vif(data_3_vif)

  # Stepwise model building
  log_mod_3_1 <- bglmer(choice ~ reward_value + uncertainty +
                          treatment * color + age + gender + major + (1 | id),
                        fixef.prior = t, data = data_3,
                        family = binomial(link = "logit"))

  log_mod_3_2 <- bglmer(choice ~ reward_value + uncertainty +
                          treatment * color + age + gender + major +
                          sequence_number + (1 | id),
                        fixef.prior = t, data = data_3,
                        family = binomial(link = "logit"))

  log_mod_3_3 <- bglmer(choice ~ reward_value + uncertainty +
                          treatment * color + age + gender + major +
                          sequence_number + reaction_time + (1 | id),
                        fixef.prior = t, data = data_3,
                        family = binomial(link = "logit"))

  log_mod_3_4 <- bglmer(choice ~ reward_value + uncertainty +
                          treatment * color + age + gender + major +
                          sequence_number + reaction_time + previous_choice +
                          (1 | id), fixef.prior = t, data = data_3,
                        family = binomial(link = "logit"))

  log_mod_3_5 <- bglmer(choice ~ reward_value + uncertainty +
                          treatment * color + age + gender + major +
                          sequence_number + reaction_time + previous_choice +
                          reward_exposure + (1 | id),
                        fixef.prior = t, data = data_3,
                        family = binomial(link = "logit"))

  s_3_pcr <- c('R^2',
               round(r2_nakagawa(log_mod_3_1)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_3_2)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_3_3)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_3_4)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_3_5)$R2_conditional, 3))
  s_3_pcn <- c('N',
               summary(log_mod_3_1)$devcomp$dims[1],
               summary(log_mod_3_2)$devcomp$dims[1],
               summary(log_mod_3_3)$devcomp$dims[1],
               summary(log_mod_3_4)$devcomp$dims[1],
               summary(log_mod_3_5)$devcomp$dims[1])

  s_3_pcr

  s_3_pcn

}
#Table 2 B and Table D. II
{

  data_5 <- data %>%
    filter(block_type == "C" & craver_2 == 1) %>%
    mutate(reward_value = factor(reward_value, levels = c("Low", "High"),
                                 labels = c("Low", "High")),
           uncertainty = factor(aaron_mood, levels = c("Low", "High"),
                                labels = c("Low", "High")),
           treatment = factor(treatment, levels = c("control", "test"),
                              labels = c("Control", "Test")),
           age = scale(age),
           gender = factor(gender),
           major = factor(major),
           reward_exposure = scale(exposure_time),
           reaction_time = scale(reaction_time),
           sequence_number = scale(sequence_number))

  log_mod_5 <- bglmer(choice ~ reward_value + uncertainty * treatment +
                        age + gender + major + sequence_number +
                        previous_choice + reward_exposure + reaction_time +
                        (1 | id), data = data_5, fixef.prior = t,
                      family = binomial(link = "logit"))

  summary(log_mod_5)

  # Nakagawa R^2
  r2_nakagawa(log_mod_5)$R2_conditional

  # Number of obs
  summary(log_mod_5)$devcomp$dims[1]

  # Multicollinearity
  data_5_vif <- data_5[,c('reward_value', 'uncertainty', 'treatment',
                          'age', 'gender', 'major',
                          'sequence_number', 'previous_choice',
                          'reward_exposure')] %>%
    mutate(reward_value = as.numeric(reward_value),
           uncertainty = as.numeric(uncertainty),
           treatment = as.numeric(treatment),
           gender = as.numeric(gender),
           major = as.numeric(major))
  vif_mod_5_out <- usdm::vif(data_5_vif)

  # Stepwise model building
  log_mod_5_1 <- bglmer(choice ~ reward_value + uncertainty * treatment +
                          age + gender + major + sequence_number + (1 | id),
                        data = data_5, fixef.prior = t,
                        family = binomial(link = "logit"))

  log_mod_5_2 <- bglmer(choice ~ reward_value + uncertainty * treatment +
                          age + gender + major + sequence_number + reaction_time +
                          (1 | id), data = data_5, fixef.prior = t,
                        family = binomial(link = "logit"))

  log_mod_5_3 <- bglmer(choice ~ reward_value + uncertainty * treatment +
                          age + gender + major + sequence_number + reaction_time +
                          previous_choice + (1 | id),
                        data = data_5, fixef.prior = t,
                        family = binomial(link = "logit"))

  log_mod_5_4 <- bglmer(choice ~ reward_value + uncertainty * treatment +
                          age + gender + major + sequence_number + reaction_time +
                          previous_choice + reward_exposure + (1 | id),
                        data = data_5, fixef.prior = t,
                        family = binomial(link = "logit"))

  s_5_pcr <- c('R^2',
               round(r2_nakagawa(log_mod_5_1)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_5_2)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_5_3)$R2_conditional, 3),
               round(r2_nakagawa(log_mod_5_4)$R2_conditional, 3))
  s_5_pcn <- c('N',
               summary(log_mod_5_1)$devcomp$dims[1],
               summary(log_mod_5_2)$devcomp$dims[1],
               summary(log_mod_5_3)$devcomp$dims[1],
               summary(log_mod_5_4)$devcomp$dims[1])

  s_5_pcr
  s_5_pcn
}

#### Model Comparison ####

#Table III for treatment effect, extended version (Table F.I), and Table IV for uncertainty effect
source(file.path(suppl_code_path, "Simulated agents_treatment effect.R"))
{cat("This is Table 3:\n")
print(table_3)}
{cat("This is the extend Table F.I in Appendix F:\n")
print(table_3_extend)}
source(file.path(suppl_code_path, "Simulated agents_uncertainty effect.R"))
{cat("This is Table 4:\n")
print(table_4)}

#Main results and Figure 7
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model Comparison with the lab data.R"))
#Option 2: direclty load the stored results obtained by us, which is adopted here
load("Model comparison with the lab data_beta40to60_exploration and loss tolerance.RData")

#Figure 6. Model fit comparisons for participant behavior
{
  #Panel A:
  dev.new(width=8, height=8)
  par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, mgp = c(3.5, 1.5, 0))
  index=which(Bet_yellow_fit>0.01)
  C=quantile(c(OOS_rational[index], OOS_CbD[index]),0.95)
  plot(OOS_rational[index], OOS_CbD[index],xlim=c(0,C), ylim=c(0,C), xlab = "negative LL of the base model",ylab="negative LL of the Pavlovian variant",pch=20,type="p",las=1,col="blue")
  abline(a=0,b=1,col="black")

  #Panel B:
  dev.new(width=8, height=8)
  par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, mgp = c(3.5, 1.5, 0))
  index=which(Bet_yellow_fit>0.01)
  C=max(OOS_rational[index], OOS_RL[index])
  plot(OOS_rational[index], OOS_RL[index],xlim=c(0,C), ylim=c(0,C), xlab = "negative LL of the base model",ylab="negative LL of the RL model",pch=20,type="p",las=1,col="blue")
  abline(a=0,b=1,col="black")

  #Panel C and Panel D:
  {index=which(Bet_yellow_fit>0.01)
    Prior=rep(1/3,3)
    LL_to_Posterior=function(LL){
      LL=-1*(LL-min(LL))
      c=Prior*exp(LL)
      Posterior=c/sum(c)
      return(Posterior)
    }
    LL=rbind(OOS_RL[index],OOS_rational[index],OOS_CbD_no_uncertain[index])

    Posterior=apply(LL,2,LL_to_Posterior)
    #mean(Posterior[3,]>0.5)

    Importance_population=apply(Posterior,1, mean)
    sem <- apply(Posterior,1, sd) / dim(Posterior)[2]



    #Individual importance
    data <- data.frame(
      Probability = c(Posterior[1,], Posterior[2,], Posterior[3,]),
      Model = c(rep("RL", length(Posterior[1,])),rep("Base", length(Posterior[2,])),rep("Pavlovian", length(Posterior[3,]))),
      stringsAsFactors = FALSE
    )
    data$Model <- factor(data$Model, levels = c("RL", "Base", "Pavlovian"))

    {
      dev.new(width=12, height=9)
      im=ggplot(data, aes(x = Model, y = Probability, fill = Model)) +
        geom_violin(
          aes(fill = Model,
              fill = after_scale(colorspace::lighten(fill, .5))),  # Lighten the fill color for better visualization
          size = 1.2,
          bw = 0.1,  # Bandwidth control (smoothing parameter)
          scale = "count"  # Scale based on count (normalizes area under the curve to count)
        ) +
        scale_y_continuous(limits = c(0, 1)) +  # Limit y-axis to 0-1 for probability density
        labs(title = "",
             x = "",
             y = "Posterior probability of each Model") +
        scale_fill_manual(values = c("grey", "blue", "green")) +  # Custom colors for each model
        geom_hline(yintercept = 0.5, linetype = "dashed", color = "black", size = 1) +
        theme_minimal() +
        theme(
          axis.text = element_text(size = 25),
          axis.title.x = element_text(size = 25),
          axis.title.y = element_text(size = 25),
          legend.position = "none"  # Optional: Remove legend
        )
      print(im)
    }
    #Average importance
    {

      # Create a data frame
      data <- data.frame(
        Group = c("RL", "Base", "Pavlovian"),
        Count = Importance_population,
        SEM = sem
      )

      # Set the factor levels explicitly to control the order
      data$Group <- factor(data$Group, levels = c("RL", "Base", "Pavlovian"))

      # Add a small constant to the Count to avoid bars with height 0
      data$Count <- pmax(data$Count, 0.01)  # Ensure no bars are at zero height

      # Manually define the colors and labels for the legend
      data$FillLabel <- ifelse(data$Group == "RL", "Base", "Pavlovian")
      # Create the bar plot with error bars


      dev.new(width=8, height=8)
      im=ggplot(data, aes(x=Group, y=Count, fill=Group)) +
        geom_bar(stat = "identity", width=0.4) +
        geom_errorbar(aes(ymin = Count - SEM, ymax = Count + SEM), width = 0.2) +
        labs(title="", y="Importance of a model", x = "") +
        scale_fill_manual(values = c("grey", "blue", "green")) +
        theme_minimal() +
        theme(
          axis.text = element_text(size = 25),   # Increase tick mark size
          axis.title.x = element_text(size = 20),  # Keep x-axis label size
          axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
          axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
          legend.position = "none"
        )
      print(im)
    }
  }
}

#Paired Wilcoxon test compairing base vs. RL
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  wilcox_result <- wilcox.test(OOS_rational[index], OOS_RL[index], alternative = 'l', paired = TRUE)
  effectsize(wilcox_result)
}


#Paired Wilcoxon test compairing Pavlovian vs. base
{
index=which(Bet_yellow_fit>0.01)
wilcox_result <- wilcox.test(OOS_CbD_no_uncertain[index], OOS_rational[index], alternative = 'l', paired = TRUE)
effectsize(wilcox_result)
}

#Figure 7. Regression of DA predicting yellow betting
{
  DA_average=rep(0,N_ID)
  #Bet_yellow_fit includes the yellow betting rate of everyone

  for(ID in 1:N_ID){
    Index_yellow=which(Sequence_bank[ID,,4]==0.2)
    DA_agent=NULL
    beta_logit=Param_CbD[ID,1]
    alpha=Param_CbD[ID,2]
    lambda=Param_CbD[ID,3]
    C_kappa1=Param_CbD[ID,4]
    kappa2=Param_CbD[ID,5]
    theta=Param_CbD[ID,6]
    Stats_agent=Sequence_bank[ID,,]
    G=0
    for(t in 1:N_trial){
      if(t>2 && Stats_agent[t,3]!=Stats_agent[t-1,3]) {G=0}#Reset the influence in each sequence
      prob_win=Stats_agent[t,4]
      uncertainty=Stats_agent[t,5]
      reward=Stats_agent[t,6]
      kappa1=ifelse(uncertainty==1,C_kappa1*entropy_low,C_kappa1*entropy_high)#Kappa1 is decided by the baseline value and the entropy
      DA=max(0,1/(1+exp(-1*kappa1*G))-kappa2)
      if(Stats_agent[t,4]==0.2){
        DA_agent=c(DA_agent,DA)
      }
      G=G*theta+I(Stats_agent[t,8]>0)#There will be outcome 0 for missed trials, so the G simply decay
    }
    DA_average[ID]=mean(DA_agent)
  }


  model <- lm(Bet_yellow_fit ~ DA_average)
  print(summary(model))


  C=max(DA_average,Bet_yellow_fit)
  dev.new(width=8, height=8)
  par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, mgp = c(3.5, 1.5, 0))
  plot(DA_average,Bet_yellow_fit, xlim=c(0,C),ylim=c(0,C),xlab = "Average DA Metric",ylab="Betting Rate in Yellow Sessions",pch=20,type="p",las=1,col="blue")
  abline(model, col = "red", lwd = 2)
}

#Figure 8A. Bar plot with medians and Interquartile Ranges (IQRs)
{
  index=which(Bet_yellow_fit>0.01)
  C1=Param_CbD_two[index,4]
  C2=Param_CbD_two[index,5]
  medians <- c(median(C1), median(C2))
  IQRs <- c(IQR(C1), IQR(C2))
  plot_data <- data.frame(
    Condition = factor(c("High-uncertainty", "Low-uncertainty")),
    Median = medians,
    IQR_Lower = medians - IQRs / 2,
    IQR_Upper = medians + IQRs / 2
  )
  library(ggplot2)
  dev.new(width=8, height=8)
  ggplot(plot_data, aes(x = Condition, y = Median, fill = Condition)) +
    geom_bar(stat = "identity", width = 0.4) +
    geom_errorbar(aes(ymin = IQR_Lower, ymax = IQR_Upper), width = 0.2) +
    labs(y = expression("Median fitted value of   " * kappa[1]), x = "Condition") +
    scale_fill_manual(values = c("grey", "grey")) +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 25),   # Increase tick mark size
      axis.title.x = element_text(size = 25, margin = margin(t = 25, r = 0, b = 0, l = 0)),  # Keep x-axis label size
      axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
      axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
      legend.position = "none",
      plot.margin = margin(t = 5, r = 5, b = 30, l = 5)
    )
}

#Test for Figure 8A comparing the fitted kappa1 in high vs. low uncertainty
index=which(Bet_yellow_fit>0.01)
Kappa1=data.frame(high=Param_CbD_two[index,4], low=Param_CbD_two[index,5])
wilcox_result <- wilcox.test(Kappa1$high, Kappa1$low, alternative = 'g', paired = TRUE)
effectsize(wilcox_result)

#The percentage of participants showing the uncertainty effect
mean(Param_CbD_two[index,4]>=Param_CbD_two[index,5]*1.5)

#Figure 8B. Bayesian Wilcoxon test for the enhanced variant
{
A <- dfba_wilcoxon(OOS_CbD_no_uncertain[index], OOS_CbD[index])

a=A$a_post
b=A$b_post
phi_values <- seq(0, 1, length.out = 100)
posterior_density <- dbeta(phi_values, a, b)
dev.new(width=8, height=8)
par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, mgp = c(3.5, 1.5, 0))
plot(phi_values, posterior_density, type = "l", lwd = 2, col = "blue",
     xlab = expression(Phi[W]), ylab = "Probability density",
)

abline(v = 0.5, col = "red", lty = 2, lwd = 2)  # Thicker red dashed line for better visibility
abline(h = 1, col = "grey", lty = 2, lwd = )  # Thin green dashed line for prior
legend("topleft", legend = c("Prior", "Posterior", expression(Phi[W] == 0.5)),
       col = c("grey", "blue", "red"),  # Colors corresponding to the lines
       lty = c(2, 4, 2),  # Line types corresponding to each label
       lwd = c(2, 2, 2),  # Line widths for each label
       cex=1.5,
       bty = "n")

A
}

#Figure 8C. Model importance of original pavlovian model and sign-tracking variant
{
  Prior=rep(1/2,2)
  LL_to_Posterior=function(LL){
    LL=-1*(LL-min(LL))
    c=Prior*exp(LL)
    Posterior=c/sum(c)
    return(Posterior)
  }

  index=which(Bet_yellow_fit>0.01)
  #index=which(OOS_CbD_no_uncertain[index]<OOS_rational[index])
  LL=rbind(OOS_CbD_no_uncertain[index], OOS_CbD[index])

  Posterior=apply(LL,2,LL_to_Posterior)

  Importance_population=apply(Posterior,1, mean)
  sem <- apply(Posterior,1, sd) / dim(Posterior)[2]

  #Importance group
  {

    # Create a data frame
    data <- data.frame(
      Group = c("Original Pavlovian", "Sign-tracking Variant"),
      Count = Importance_population,
      SEM = sem
    )

    # Set the factor levels explicitly to control the order
    data$Group <- factor(data$Group, levels = c("Original Pavlovian", "Sign-tracking Variant"))

    # Add a small constant to the Count to avoid bars with height 0
    data$Count <- pmax(data$Count, 0.01)  # Ensure no bars are at zero height


    # Create the bar plot with error bars
    dev.new(width=12, height=8)
    im=ggplot(data, aes(x=Group, y=Count, fill=Group)) +
      geom_bar(stat = "identity", width=0.4) +
      geom_errorbar(aes(ymin = Count - SEM, ymax = Count + SEM), width = 0.2) +
      labs(title="", y="Importance of a model", x = "") +
      scale_fill_manual(values = c("lightgreen","palegreen4")) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 25),   # Increase tick mark size
        axis.title.x = element_text(size = 20),  # Keep x-axis label size
        axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
        axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
        legend.position = "none",
        plot.margin = margin(t = 30)
      )
    print(im)
  }
}

#Figure 9A. Frustration theory
{

  load("Data Bank.RData")


  control=1:99
  test=100:198
  control_blue_index=(Sequence_bank[control,,4]==0.8)
  control_yellow_index=(Sequence_bank[control,,4]==0.2)
  test_blue_index=(Sequence_bank[test,,4]==0.8)
  test_yellow_index=(Sequence_bank[test,,4]==0.2)
  high_uncerainty_yellow_index=(Sequence_bank[,,5]==0.5 & Sequence_bank[,,4]==0.2)
  high_uncerainty_blue_index=(Sequence_bank[,,5]==0.5 & Sequence_bank[,,4]==0.8)
  low_uncerainty_yellow_index=(Sequence_bank[,,5]==1 & Sequence_bank[,,4]==0.2)
  low_uncerainty_blue_index=(Sequence_bank[,,5]==1 & Sequence_bank[,,4]==0.8)


  Choice_lab=Sequence_bank[,,7]
  Outcome_lab=Sequence_bank[,,8]
  #Uncertainty effect
  mean(Choice_lab[low_uncerainty_yellow_index])
  mean(Choice_lab[high_uncerainty_yellow_index])


  frustration_index_yellow=matrix(FALSE,dim(Sequence_bank)[1],dim(Sequence_bank)[2])
  index_after_yellow_bet=matrix(FALSE,dim(Sequence_bank)[1],dim(Sequence_bank)[2])
  frustration_index_blue=matrix(FALSE,dim(Sequence_bank)[1],dim(Sequence_bank)[2])


  for(i in 1:dim(Sequence_bank)[1]){
    for( j in 1:dim(Sequence_bank)[2]){
      if(Sequence_bank[i,j,4]==0.2
         && Sequence_bank[i,j,5]==0.5
         && Sequence_bank[i,j,7]==1
         && Sequence_bank[i,j,8]==0){#yellow, bet, but rejected
        if(j<dim(Sequence_bank)[2] && Sequence_bank[i,j+1,4]==0.2){#The next trial is still yellow
          frustration_index_yellow[i,j+1]=TRUE
        }
      }
      if(Sequence_bank[i,j,4]==0.2
         && Sequence_bank[i,j,5]==0.5
         && Sequence_bank[i,j,7]==1
         && Sequence_bank[i,j,8]!=0){#yellow, bet, and see the outcome
        if(j<dim(Sequence_bank)[2] && Sequence_bank[i,j+1,4]==0.2){#The next trial is still yellow
          index_after_yellow_bet[i,j+1]=TRUE
        }
      }
      if(Sequence_bank[i,j,4]==0.8
         && Sequence_bank[i,j,7]==1
         && Sequence_bank[i,j,8]==0){#blue, bet, but rejected
        if(j<dim(Sequence_bank)[2] && Sequence_bank[i,j+1,4]==0.8){#The next trial is still yellow
          frustration_index_blue[i,j+1]=TRUE
        }
      }
    }
  }

  cat("The average betting rate after betting and being rejected in yellow sessions is ", mean(Choice_lab[frustration_index_yellow]), "\n")
  cat("The average betting rate after betting and seeing outcomes in yellow sessions is ", mean(Choice_lab[index_after_yellow_bet]), "\n")
  Rate_low_uncertain=rep(0,198)
  Rate_high_uncertain=rep(0,198)
  No=(frustration_index_yellow==FALSE)#exclude the frustration trials
  No=high_uncerainty_yellow_index * No #index of high-uncertainty trails without frustration
  for(i in 1:198){
    x=Choice_lab[i,low_uncerainty_yellow_index[i,]]
    y=Choice_lab[i,No[i,]==1]
    Rate_low_uncertain[i]=mean(x)
    Rate_high_uncertain[i]=mean(y)
  }


  {
    A <- dfba_wilcoxon(Rate_high_uncertain, Rate_low_uncertain)
    kurtosis(Rate_high_uncertain-Rate_low_uncertain)

    a=A$a_post
    b=A$b_post
    phi_values <- seq(0, 1, length.out = 100)
    posterior_density <- dbeta(phi_values, a, b)
    dev.new(width=8, height=8)
    par(mar = c(5, 5.5, 4, 2) + 0.7,cex.lab = 2, mgp = c(3.5, 1.5, 0))
    plot(phi_values, posterior_density, type = "l", lwd = 2, col = "blue",
         xlab = expression(Phi[W]), ylab = "Probability density",
    )

    abline(v = 0.5, col = "red", lty = 2, lwd = 2)  # Thicker red dashed line for better visibility
    abline(h = 1, col = "grey", lty = 2, lwd = )  # Thin green dashed line for prior
    legend("topleft", legend = c("Prior", "Posterior", expression(Phi[W] == 0.5)),
           col = c("grey", "blue", "red"),  # Colors corresponding to the lines
           lty = c(2, 4, 2),  # Line types corresponding to each label
           lwd = c(2, 2, 2),  # Line widths for each label
           cex=1.5,
           bty = "n")

    print(A)
  }
}

#Figure 9B. Suspense theory group evidence
{
  #Option 1: process the data by yourself which may take a while, just remove the # in the below line
  #source(file.path(suppl_code_path, "Suspense-augmented variant.R"))
  #Option 2: direclty load the stored results obtained by us, which is adopted here
  load("Model comparison with the lab data_beta40to60_suspense10_augmented_Pavlovian.RData")
  index=which(Bet_yellow_fit>0.01)
  Prior=c(1/2,1/2)
  LL_to_Posterior=function(LL){
    LL=-1*(LL-min(LL))
    c=Prior*exp(LL)
    Posterior=c/sum(c)
    return(Posterior)
  }

  index=which(Bet_yellow_fit>0.01)
  LL=rbind(OOS_CbD_suspense_no_uncertain[index], OOS_CbD[index])
  Posterior=apply(LL,2,LL_to_Posterior)
  Importance_population=apply(Posterior,1, mean)
  sem <- apply(Posterior,1, sd) / dim(Posterior)[2]
    # Create a data frame
    data <- data.frame(
      Group = c("Pavlovian + suspense", "Sign-tracking"),
      Count = Importance_population,
      SEM = sem
    )

    # Set the factor levels explicitly to control the order
    data$Group <- factor(data$Group, levels = c("Pavlovian + suspense", "Sign-tracking"))

    # Add a small constant to the Count to avoid bars with height 0
    data$Count <- pmax(data$Count, 0.01)  # Ensure no bars are at zero height


    # Create the bar plot with error bars
    dev.new(width=8, height=8)
    im=ggplot(data, aes(x=Group, y=Count, fill=Group)) +
      geom_bar(stat = "identity", width=0.4) +
      geom_errorbar(aes(ymin = Count - SEM, ymax = Count + SEM), width = 0.2) +
      labs(title="", y="Model Importance", x = "") +
      scale_fill_manual(values = c("lightgreen","palegreen4")) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 25),   # Increase tick mark size
        axis.title.x = element_text(size = 20),  # Keep x-axis label size
        axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
        axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
        legend.position = "none",
        plot.margin = margin(t = 30)
      )
    print(im)
}
#Individual test: “Pavlovian + suspense” model vs. sign-tracking
{
  wilcox_result <- wilcox.test(OOS_CbD_suspense_no_uncertain[index], OOS_CbD[index], alternative = 'g', paired = TRUE)
  print(wilcox_result)
  effectsize(wilcox_result)

}

#### Appendix ####
#Incentive effects of alternative payment rules.----
source(file.path(suppl_code_path, "payoff rule.R"))
#The probability of getting a positive outcome under the "pay one" rule
mean(payoff_1_optimal>0)#optimal
mean(payoff_1_25>0)#25% in yellow
mean(payoff_1_50>0)#50% in yellow
mean(payoff_1_75>0)#75% in yellow

#The probability of getting a positive outcome under our payoff rule
mean(payoff_2_optimal>0)#optimal
mean(payoff_2_25>0)#25% in yellow
mean(payoff_2_50>0)#50% in yellow
mean(payoff_2_75>0)#75% in yellow

#Model Recovery procedures----

#STEP 1 : Simulate Pavlovian agents and run model comparison
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model recovery with simulated Pavlovian agents_no uncertainty effect.R"))
#Option 2: direclty load the results stored by us, which is adopted here
load("Model Recovery with simulated CbD agents and no uncertainty effect_low trembling_40to60.RData")
index=which(Bet_yellow_fit>0.01)
#Percentage of maladpative bettors where the Pavlovian model outperforms the base model
mean(OOS_CbD_no_uncertain[index]<OOS_rational[index])
#Pavlovian vs. base
{
  index=which(Bet_yellow_fit>0.01)
  wilcox_result <- wilcox.test(OOS_CbD_no_uncertain[index], OOS_rational[index], alternative = 'l', paired = TRUE)
  effectsize(wilcox_result)
}
#Base vs. RL
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  wilcox_result <- wilcox.test(OOS_rational[index], OOS_RL[index], alternative = 'l', paired = TRUE)
  effectsize(wilcox_result)
}

#STEP 2: Simulate RL agents and run model comparison
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model Recovery with simulated RL agents.R"))
#Option 2: direclty load the results stored by us, which is adopted here
load("Model Recovery with simulated RL agents.RData")
index=which(Bet_yellow_fit>0.01)
#Percentage of maladpative bettors where the RL model outperforms the base model
mean(OOS_rational[index]<OOS_RL[index])

#STEP 3: Simulate Pavlovian agents, with half subject to uncertainty effect
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model recovery with simulated Pavlovian agents_mixed uncertainty effect.R"))
#Option 2: direclty load the results stored by us, which is adopted here
load("Model recovery with a mixed uncertainty effect_low_trembling_40to60_same parameter as previous recovery.RData")

#enhanced Pavlovian model demonstrates superior fit compared to the original model
{
  index=which(Bet_yellow_fit>0.01)
  #wilcox.test(OOS_CbD_no_uncertain[index], OOS_CbD[index], alternative = 'g', paired = TRUE)
  A <- dfba_wilcoxon(OOS_CbD_no_uncertain[index], OOS_CbD[index])
  print(A)
}
#significantly higher κ1 values in high-uncertainty trials
{
  index=which(Bet_yellow_fit>0.01)
  Kappa1=data.frame(high=Param_CbD_two[index,4], low=Param_CbD_two[index,5])
  wilcox_result <- wilcox.test(Kappa1$high, Kappa1$low, alternative = 'g', paired = TRUE)
  effectsize(wilcox_result)
}
#The number of participants showing the uncertainty effect
{
  index_uncertainty=c(1:50,100:150) #The percentage of participants with CbD effect
  index_no_uncertainty=c(51:99,151:198) #The percentage of participants with no CbD effect
  recovery_uncertainty=index_uncertainty[Bet_yellow_fit[index_uncertainty]>0.01]
  recovery_no_uncertainty=index_no_uncertainty[Bet_yellow_fit[index_no_uncertainty]>0.01]

  cat("Our criterion identified the number of maladaptive bettors with uncertainty effect is", sum(Param_CbD_two[index,4]>=Param_CbD_two[index,5]*1.5),
      "\n The true number of maladaptive bettors programmed with the effect is", length(recovery_uncertainty))
}

#STEP 4: Simulate Pavlovian agents, without uncertainty effect
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model recovery with simulated Pavlovian agents_no uncertainty effect.R"))
#Option 2: direclty load the results stored by us, which is adopted here
load("Model Recovery with simulated CbD agents and no uncertainty effect_low trembling_40to60.RData")
{
  index=which(Bet_yellow_fit>0.01)
  A <- dfba_wilcoxon(OOS_CbD[index],OOS_CbD_no_uncertain[index])
  print(A)#Now the model without uncertainty effect outperform with a small LL
}
{
  index=which(Bet_yellow_fit>0.01)
  Kappa1=data.frame(high=Param_CbD_two[index,4], low=Param_CbD_two[index,5])
  wilcox_result <- wilcox.test(Kappa1$high, Kappa1$low, alternative = 'g', paired = TRUE)
}

#Robustness check-----
#Undirected exploraion and loss aversion
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model Comparison with the lab data.R"))
#Option 2: direclty load the stored results obtained by us, which is adopted here
load("Model comparison with the lab data_beta40to60_exploration and loss tolerance.RData")

#The base model fits better than the RL with undirected exploration
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  wilcox_result <- wilcox.test(OOS_rational[index], OOS_RL_explore[index], alternative = 'l', paired = TRUE)
  effectsize(wilcox_result)
}

#The Pavlovian model fits better than the RL with context dependence
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  wilcox_result <- wilcox.test(OOS_CbD_no_uncertain[index], OOS_context_RL[index], alternative = 'l', paired = TRUE)
  effectsize(wilcox_result)
}

#The Pavlovian model fits better than the base model with loss aversion
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  A <- dfba_wilcoxon(OOS_rational_tolerance[index], OOS_CbD_no_uncertain_tolerance[index])
  print(A)
}

#The Pavlovian utility model fits better than the base model
{
  index=which(Bet_yellow_fit>0.01)#bet at least twice in yellow sessions, bet prob>= 2/120
  wilcox_result <- wilcox.test(OOS_CbD_v[index], OOS_rational[index], alternative = 'l', paired = TRUE)
  wilcox_result
  effectsize(wilcox_result)
}

#Running on all samples instead of only maladaptive bettors---------
#Pavlovian still outperforms
{
Prior=rep(1/3,3)
LL_to_Posterior=function(LL){
  LL=-1*(LL-min(LL))
  c=Prior*exp(LL)
  Posterior=c/sum(c)
  return(Posterior)
}
LL=rbind(OOS_RL,OOS_rational,OOS_CbD_no_uncertain)

Posterior=apply(LL,2,LL_to_Posterior)


Importance_population=apply(Posterior,1, mean)
sem <- apply(Posterior,1, sd) / dim(Posterior)[2]


#Average importance
{

  # Create a data frame
  data <- data.frame(
    Group = c("RL", "Base", "Pavlovian"),
    Count = Importance_population,
    SEM = sem
  )

  # Set the factor levels explicitly to control the order
  data$Group <- factor(data$Group, levels = c("RL", "Base", "Pavlovian"))

  # Add a small constant to the Count to avoid bars with height 0
  data$Count <- pmax(data$Count, 0.01)  # Ensure no bars are at zero height

  # Manually define the colors and labels for the legend
  data$FillLabel <- ifelse(data$Group == "RL", "Base", "Pavlovian")
  # Create the bar plot with error bars


  dev.new(width=8, height=8)
  im=ggplot(data, aes(x=Group, y=Count, fill=Group)) +
    geom_bar(stat = "identity", width=0.4) +
    geom_errorbar(aes(ymin = Count - SEM, ymax = Count + SEM), width = 0.2) +
    labs(title="", y="Importance of a model", x = "") +
    scale_fill_manual(values = c("grey", "blue", "green")) +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 25),   # Increase tick mark size
      axis.title.x = element_text(size = 20),  # Keep x-axis label size
      axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
      axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
      legend.position = "none"
    )
  print(im)
}
}


#Allow for high choice randomness--------
#Option 1: process the data by yourself which may take a while, just remove the # in the below line
#source(file.path(suppl_code_path, "Model Comparison with the lab data_full samples and choice randomness.R"))
#Option 2: direclty load the stored results obtained by us, which is adopted here
load("Model comparison with the lab data_high trembling_10to60.RData")

#Pavlovian still outperforms
{index=which(Bet_yellow_fit>0.01)
  Prior=rep(1/3,3)
  LL_to_Posterior=function(LL){
    LL=-1*(LL-min(LL))
    c=Prior*exp(LL)
    Posterior=c/sum(c)
    return(Posterior)
  }
  LL=rbind(OOS_RL[index],OOS_rational[index],OOS_CbD_no_uncertain[index])

  Posterior=apply(LL,2,LL_to_Posterior)
  #mean(Posterior[3,]>0.5)

  Importance_population=apply(Posterior,1, mean)
  sem <- apply(Posterior,1, sd) / dim(Posterior)[2]

  #Average importance
  {

    # Create a data frame
    data <- data.frame(
      Group = c("RL", "Base", "Pavlovian"),
      Count = Importance_population,
      SEM = sem
    )

    # Set the factor levels explicitly to control the order
    data$Group <- factor(data$Group, levels = c("RL", "Base", "Pavlovian"))

    # Add a small constant to the Count to avoid bars with height 0
    data$Count <- pmax(data$Count, 0.01)  # Ensure no bars are at zero height

    # Manually define the colors and labels for the legend
    data$FillLabel <- ifelse(data$Group == "RL", "Base", "Pavlovian")
    # Create the bar plot with error bars


    dev.new(width=8, height=8)
    im=ggplot(data, aes(x=Group, y=Count, fill=Group)) +
      geom_bar(stat = "identity", width=0.4) +
      geom_errorbar(aes(ymin = Count - SEM, ymax = Count + SEM), width = 0.2) +
      labs(title="", y="Importance of a model", x = "") +
      scale_fill_manual(values = c("grey", "blue", "green")) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 25),   # Increase tick mark size
        axis.title.x = element_text(size = 20),  # Keep x-axis label size
        axis.title.y = element_text(size = 25, margin = margin(t = 0, r = 20, b = 0, l = 0)),  # Increase y-axis label size and add margin
        axis.ticks.length = unit(0.3, "cm"),  # Increase tick length
        legend.position = "none"
      )
    print(im)
  }
}
###THE END
