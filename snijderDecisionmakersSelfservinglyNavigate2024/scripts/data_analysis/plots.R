# Libraries
library(readr)
library(ggplot2)
library(dplyr)
library(lme4)
library(lmerTest)
library(RColorBrewer)
library(tidyr)
library(ineq)
library(car)
library(reshape2)
library(multcomp)

#load functions
sem <- function(x, na.rm=F)  { 
  dev <- sd(x, na.rm=na.rm)
  len <- ifelse(na.rm == T, length(x[!is.na(x)]), length(x))
  stderror <- dev/sqrt(len)
  return(stderror)
} 

agg_switch <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else mean(x)
agg_switch_sem <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sem(x)
agg_switch_sum <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sum(x)
agg_switch_na.rm <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else mean(x, na.rm=T)
agg_switch_sem.rm <- function(x) if(is.factor(x) | is.character(x)) unique(x)[1] else sem(x, na.rm=T)

plotprepare <- function(...) {
  
  par(bty='n', 
      cex=0.8,
      las=1, 
      ann=T, 
      lwd=2, 
      mar=c(5, 4, 2, 1), 
      oma=c(0,0,0,0), 
      pch=19, 
      xpd=T, 
      cex.axis=0.85, 
      mgp=c(2.5, 0.72, 0),
      tcl=-0.4, ...
  )
  
}

HHcol <- '#B51700'
LLcol <- '#014D7F'
HLcol <- 'darkgrey'
LHcol <- 'lightgrey'
cooperationCol <- '#01a300'

###################################################################################################################################

### Prepare data

dat = read_csv("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/dat_institutions.csv")
head(dat)

dat_long = read_csv("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/dat_long.csv")
head(dat_long)

dat_fair = read_csv("snijderDecisionmakersSelfservinglyNavigate2024/scripts/data_analysis/dat_fair.csv")
head(dat_fair)

###################################################################################################################################

### Figure 1

## Panel A

#create data-frames for mixed and segregated pairs for created HH-LL or HL-LH types
dat_HHLL_mix = dat_long[(dat_long$type == "HH" | dat_long$type == "LL") & (dat_long$pair == "HH_LL"),]
dat_HHLL_seg = dat_long[(dat_long$type == "HH" | dat_long$type == "LL") & (dat_long$pair == "HH_HH" | dat_long$pair == "LL_LL"),]
dat_HLLH_mix = dat_long[(dat_long$type == "HL" | dat_long$type == "LH") & (dat_long$pair == "HL_LH"),]
dat_HLLH_seg = dat_long[(dat_long$type == "HL" | dat_long$type == "LH") & (dat_long$pair == "HL_HL" | dat_long$pair == "LH_LH"),]

#calculate averages per type
dat_HHLL_mix_avg <- aggregate(dat_HHLL_mix, by=list(dat_HHLL_mix$type), agg_switch)
dat_HHLL_seg_avg <- aggregate(dat_HHLL_seg, by=list(dat_HHLL_seg$type), agg_switch)
dat_HLLH_mix_avg <- aggregate(dat_HLLH_mix, by=list(dat_HLLH_mix$type), agg_switch)
dat_HLLH_seg_avg <- aggregate(dat_HLLH_seg, by=list(dat_HLLH_seg$type), agg_switch)

#calculate Gini coefficients
gini_HHLL_mix <- ineq(dat_HHLL_mix_avg$earn, type = "Gini")
gini_HHLL_seg <- ineq(dat_HHLL_seg_avg$earn, type = "Gini")
gini_HLLH_mix <- ineq(dat_HLLH_mix_avg$earn, type = "Gini")
gini_HLLH_seg <- ineq(dat_HLLH_seg_avg$earn, type = "Gini")

#calculate average generated wealth
wealth_HHLL_mix <- mean((dat_HHLL_mix_avg$earn - dat_HHLL_mix_avg$endowment))
wealth_HHLL_seg <- mean((dat_HHLL_seg_avg$earn - dat_HHLL_seg_avg$endowment))
wealth_HLLH_mix <- mean((dat_HLLH_mix_avg$earn - dat_HLLH_seg_avg$endowment))
wealth_HLLH_seg <- mean((dat_HLLH_seg_avg$earn - dat_HLLH_mix_avg$endowment))

#create combined data for Gini coefficients
combined_data_gini <- data.frame(
  type = c("gini_HHLL_seg", "gini_HHLL_mix", "gini_HLLH_seg", "gini_HLLH_mix"),
  gini = c(gini_HHLL_seg, gini_HHLL_mix, gini_HLLH_seg, gini_HLLH_mix)
)

#create combined data for generated wealth
combined_data_wealth <- data.frame(
  type = c("wealth_HHLL_seg", "wealth_HHLL_mix", "wealth_HLLH_seg", "wealth_HLLH_mix"),
  wealth = c(wealth_HHLL_seg, wealth_HHLL_mix, wealth_HLLH_seg, wealth_HLLH_mix)
)

#remove the "gini_" & "wealth_" from variables
combined_data_gini$type <- gsub("gini_", "", combined_data_gini$type)
combined_data_wealth$type <- gsub("wealth_", "", combined_data_wealth$type)

#merge by "type"
combined_data <- merge(combined_data_gini, combined_data_wealth, by = "type")

#filter data for types
selected_types <- c("HHLL_seg", "HHLL_mix", "HLLH_seg", "HLLH_mix")
filtered_data <- combined_data[combined_data$type %in% selected_types, ]

#create pair variable
filtered_data$pair <- ifelse(filtered_data$type %in% c("HHLL_seg", "HHLL_mix"), "HHLL", "HLLH")

#standardize wealth between 0 and 1
filtered_data$standardized_wealth <- (filtered_data$wealth - min(filtered_data$wealth)) / (max(filtered_data$wealth) - min(filtered_data$wealth))

#standardize wealth based on max possible wealth
filtered_data$standardized_wealth_max <- (filtered_data$wealth - 0) / ( (75*1.7-75) - 0)

#reverse Gini coefficient
filtered_data$gini_rev <- 1 - filtered_data$gini

#plot
ggplot(filtered_data, aes(x = type)) +
  geom_point(aes(y = gini_rev, color = "gini"), size = 3, alpha = 0.8) +
  geom_point(aes(y = standardized_wealth, color = "wealth"), size = 3, alpha = 0.8) +
  geom_path(aes(y = gini_rev, group = pair, color = "gini"), size = 0.8, linetype = "solid") +
  geom_path(aes(y = standardized_wealth, group = pair, color = "wealth"), size = 0.8, linetype = "solid") +
  labs(x = "type",
       y = "coefficient",
       color = " ") +
  scale_color_manual(values = c("#27AE60", "#8E44AD"), labels = c("equality", "wealth")) +
  theme_bw() +
  theme(
    text = element_text(size = 18),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  ) +
  ylim(0, 1)

#end



## Panel B

#create data for partners assigned to HH types
pairHH = data.frame(matrix(ncol = 3, nrow = 500))
pairHH$X1 = "HH"
pairHH$X2 = dat$create_pairs_HH
pairHH$X3 = dat$type
pairHH

#create data for partners assigned to HL types
pairHL = data.frame(matrix(ncol = 3, nrow = 500))
pairHL$X1 = "HL"
pairHL$X2 = dat$create_pairs_HL
pairHL$X3 = dat$type
pairHL

#create data for partners assigned to LH types
pairLH = data.frame(matrix(ncol = 3, nrow = 500))
pairLH$X1 = "LH"
pairLH$X2 = dat$create_pairs_LH
pairLH$X3 = dat$type
pairLH

#create data for partners assigned to LL types
pairLL = data.frame(matrix(ncol = 3, nrow = 500))
pairLL$X1 = "LL"
pairLL$X2 = dat$create_pairs_LL
pairLL$X3 = dat$type
pairLL

#create data for partners assigned to all types
dat_create_pairs = rbind(pairHH,pairHL,pairLH,pairLL)

#calculate frequency that partners were assigned to types
freq = table(dat_create_pairs$X1, dat_create_pairs$X2, dat_create_pairs$X3)
freq = as.data.frame(freq)
freq$Var1 = factor(freq$Var1, levels = c("LL", "LH", "HL", "HH"))
freq$Var2 = factor(freq$Var2, levels = c("LL", "LH", "HL", "HH"))
freq$Var3 = factor(freq$Var3, levels = c("TP", "LL", "LH", "HL", "HH"))

#create variable with pair information
freq$pair = NA
freq$pair = ifelse(freq$Var1 == "HH" & freq$Var2 == "HH", "HH_HH", freq$pair)
freq$pair = ifelse(freq$Var1 == "HH" & freq$Var2 == "HL", "HH_HL", freq$pair)
freq$pair = ifelse(freq$Var1 == "HH" & freq$Var2 == "LH", "HH_LH", freq$pair)
freq$pair = ifelse(freq$Var1 == "HH" & freq$Var2 == "LL", "HH_LL", freq$pair)

freq$pair = ifelse(freq$Var1 == "HL" & freq$Var2 == "HH", "HH_HL", freq$pair)
freq$pair = ifelse(freq$Var1 == "HL" & freq$Var2 == "HL", "HL_HL", freq$pair)
freq$pair = ifelse(freq$Var1 == "HL" & freq$Var2 == "LH", "HL_LH", freq$pair)
freq$pair = ifelse(freq$Var1 == "HL" & freq$Var2 == "LL", "HL_LL", freq$pair)

freq$pair = ifelse(freq$Var1 == "LH" & freq$Var2 == "HH", "HH_LH", freq$pair)
freq$pair = ifelse(freq$Var1 == "LH" & freq$Var2 == "HL", "HL_LH", freq$pair)
freq$pair = ifelse(freq$Var1 == "LH" & freq$Var2 == "LH", "LH_LH", freq$pair)
freq$pair = ifelse(freq$Var1 == "LH" & freq$Var2 == "LL", "LH_LL", freq$pair)

freq$pair = ifelse(freq$Var1 == "LL" & freq$Var2 == "HH", "HH_LL", freq$pair)
freq$pair = ifelse(freq$Var1 == "LL" & freq$Var2 == "HL", "HL_LL", freq$pair)
freq$pair = ifelse(freq$Var1 == "LL" & freq$Var2 == "LH", "LH_LL", freq$pair)
freq$pair = ifelse(freq$Var1 == "LL" & freq$Var2 == "LL", "LL_LL", freq$pair)

names(freq)[names(freq) == "Var1"] <- "type"
names(freq)[names(freq) == "Var2"] <- "partner_type"
names(freq)[names(freq) == "Var3"] <- "third-party type"

#calculate how much types earned on average for each partner type
agg = aggregate(dat_long$earn, by=list(dat_long$type, dat_long$partner_type, dat_long$pair), agg_switch)

names(agg)[names(agg) == "Group.1"] <- "type"
names(agg)[names(agg) == "Group.2"] <- "partner_type"
names(agg)[names(agg) == "Group.3"] <- "pair"
names(agg)[names(agg) == "x"] <- "earn"

#merge earnings data with frequency data
merged_data <- merge(freq, agg, by = c("type", "partner_type", "pair"))

#calculate weighted mean of earnings based on the frequency that they were paired
merged_data_TP <- merged_data[merged_data$`third-party type` == "TP",]
TP_HH = weighted.mean(merged_data_TP[merged_data_TP$type == "HH",]$earn, merged_data_TP[merged_data_TP$type == "HH",]$Freq)
TP_HL = weighted.mean(merged_data_TP[merged_data_TP$type == "HL",]$earn, merged_data_TP[merged_data_TP$type == "HL",]$Freq)
TP_LH = weighted.mean(merged_data_TP[merged_data_TP$type == "LH",]$earn, merged_data_TP[merged_data_TP$type == "LH",]$Freq)
TP_LL = weighted.mean(merged_data_TP[merged_data_TP$type == "LL",]$earn, merged_data_TP[merged_data_TP$type == "LL",]$Freq)
TP_earn = rbind(TP_HH,TP_HL,TP_LH,TP_LL)

merged_data_HH <- merged_data[merged_data$`third-party type` == "HH",]
HH_HH = weighted.mean(merged_data_HH[merged_data_HH$type == "HH",]$earn, merged_data_HH[merged_data_HH$type == "HH",]$Freq)
HH_HL = weighted.mean(merged_data_HH[merged_data_HH$type == "HL",]$earn, merged_data_HH[merged_data_HH$type == "HL",]$Freq)
HH_LH = weighted.mean(merged_data_HH[merged_data_HH$type == "LH",]$earn, merged_data_HH[merged_data_HH$type == "LH",]$Freq)
HH_LL = weighted.mean(merged_data_HH[merged_data_HH$type == "LL",]$earn, merged_data_HH[merged_data_HH$type == "LL",]$Freq)
HH_earn = rbind(HH_HH,HH_HL,HH_LH,HH_LL)

merged_data_HL <- merged_data[merged_data$`third-party type` == "HL",]
HL_HH = weighted.mean(merged_data_HL[merged_data_HL$type == "HH",]$earn, merged_data_HL[merged_data_HL$type == "HH",]$Freq)
HL_HL = weighted.mean(merged_data_HL[merged_data_HL$type == "HL",]$earn, merged_data_HL[merged_data_HL$type == "HL",]$Freq)
HL_LH = weighted.mean(merged_data_HL[merged_data_HL$type == "LH",]$earn, merged_data_HL[merged_data_HL$type == "LH",]$Freq)
HL_LL = weighted.mean(merged_data_HL[merged_data_HL$type == "LL",]$earn, merged_data_HL[merged_data_HL$type == "LL",]$Freq)
HL_earn = rbind(HL_HH,HL_HL,HL_LH,HL_LL)

merged_data_LH <- merged_data[merged_data$`third-party type` == "LH",]
LH_HH = weighted.mean(merged_data_LH[merged_data_LH$type == "HH",]$earn, merged_data_LH[merged_data_LH$type == "HH",]$Freq)
LH_HL = weighted.mean(merged_data_LH[merged_data_LH$type == "HL",]$earn, merged_data_LH[merged_data_LH$type == "HL",]$Freq)
LH_LH = weighted.mean(merged_data_LH[merged_data_LH$type == "LH",]$earn, merged_data_LH[merged_data_LH$type == "LH",]$Freq)
LH_LL = weighted.mean(merged_data_LH[merged_data_LH$type == "LL",]$earn, merged_data_LH[merged_data_LH$type == "LL",]$Freq)
LH_earn = rbind(LH_HH,LH_HL,LH_LH,LH_LL)

merged_data_LL <- merged_data[merged_data$`third-party type` == "LL",]
LL_HH = weighted.mean(merged_data_LL[merged_data_LL$type == "HH",]$earn, merged_data_LL[merged_data_LL$type == "HH",]$Freq)
LL_HL = weighted.mean(merged_data_LL[merged_data_LL$type == "HL",]$earn, merged_data_LL[merged_data_LL$type == "HL",]$Freq)
LL_LH = weighted.mean(merged_data_LL[merged_data_LL$type == "LH",]$earn, merged_data_LL[merged_data_LL$type == "LH",]$Freq)
LL_LL = weighted.mean(merged_data_LL[merged_data_LL$type == "LL",]$earn, merged_data_LL[merged_data_LL$type == "LL",]$Freq)
LL_earn = rbind(LL_HH,LL_HL,LL_LH,LL_LL)

#Gini coefficients 
ineq(TP_earn, type = "Gini")
ineq(HH_earn, type = "Gini")
ineq(HL_earn, type = "Gini")
ineq(LH_earn, type = "Gini")
ineq(LL_earn, type = "Gini")

#average generated wealth
mean(c((TP_earn[1]-75), (TP_earn[2]-75), (TP_earn[3]-25), (TP_earn[4]-25)))
mean(c((HH_earn[1]-75), (HH_earn[2]-75), (HH_earn[3]-25), (HH_earn[4]-25)))
mean(c((HL_earn[1]-75), (HL_earn[2]-75), (HL_earn[3]-25), (HL_earn[4]-25)))
mean(c((LH_earn[1]-75), (LH_earn[2]-75), (LH_earn[3]-25), (LH_earn[4]-25)))
mean(c((LL_earn[1]-75), (LL_earn[2]-75), (LL_earn[3]-25), (LL_earn[4]-25)))

#create data
dat_plot = data.frame(matrix(ncol = 5, nrow = 5))
dat_plot$X1 = c("TP", "HH", "HL", "LH", "LL")
dat_plot$X2 = c(ineq(TP_earn, type = "Gini"), ineq(HH_earn, type = "Gini"), ineq(HL_earn, type = "Gini"), ineq(LH_earn, type = "Gini"), ineq(LL_earn, type = "Gini"))
dat_plot$X3 = c(mean(c((TP_earn[1]-75), (TP_earn[2]-75), (TP_earn[3]-25), (TP_earn[4]-25))), 
                mean(c((HH_earn[1]-75), (HH_earn[2]-75), (HH_earn[3]-25), (HH_earn[4]-25))),
                mean(c((HL_earn[1]-75), (HL_earn[2]-75), (HL_earn[3]-25), (HL_earn[4]-25))),
                mean(c((LH_earn[1]-75), (LH_earn[2]-75), (LH_earn[3]-25), (LH_earn[4]-25))),
                mean(c((LL_earn[1]-75), (LL_earn[2]-75), (LL_earn[3]-25), (LL_earn[4]-25))))

#compare with the optimal (lowest) Gini and optimal (highest) welfare
dat_plot$X4 = (dat_plot$X2 - min(filtered_data$gini)) / min(filtered_data$gini) * 100
dat_plot$X5 = (dat_plot$X3 - max(filtered_data$wealth)) / max(filtered_data$wealth) * 100
dat_plot$X5 <- abs(dat_plot$X5)

#convert X1 to a factor to specify order
dat_plot$X1 <- factor(dat_plot$X1, levels = unique(dat_plot$X1))

#change data to long format
df_long <- melt(dat_plot, id.vars = "X1", measure.vars = c("X4", "X5"))

df_long$X1 = factor(df_long$X1, levels = c("HH", "HL", "LH", "LL", "TP"))

#plot
p <- ggplot(df_long, aes(x = X1, y = value, color = variable)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +  
  labs(x = "third-pary type",
       y = "deviation from optimal decision (%)",
       color = " ") +
  scale_color_manual(values = c("#27AE60", "#8E44AD"), labels = c("equality", "wealth")) +
  theme_bw() +
  theme(
    text = element_text(size = 18),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  ) +
  ylim(0, 100)

dot_width <- 0.2
p + geom_segment(data = subset(df_long, variable == "X4"), 
                 aes(x = as.numeric(X1) - 0.125, y = value, xend = as.numeric(X1) - 0.125, yend = 0, color = variable), 
                 position = position_dodge(width = 0.5), size = 0.8) +
    geom_segment(data = subset(df_long, variable == "X5"), 
                 aes(x = as.numeric(X1) + 0.125, y = value, xend = as.numeric(X1) + 0.125, yend = 0, color = variable), 
                 position = position_dodge(width = 0.5), size = 0.8)

#end

###################################################################################################################################

### Figure 2

#create data based on how decision-makers created types
dat_createHHLL = dat[dat$create_types == "HH-LL",]
dat_createHLLH = dat[dat$create_types == "HL-LH",]

#create dummy that captures if decision-makers, for the types they previously created, subsequently created mixed or segregation pairs
dat_createHHLL$HHLL_mix = ifelse(dat_createHHLL$create_pairs_HH == "LL" & dat_createHHLL$create_pairs_LL == "HH",
                                 1,0)
dat_createHHLL$HHLL_seg = ifelse(dat_createHHLL$create_pairs_HH == "HH" & dat_createHHLL$create_pairs_LL == "LL",
                                 1,0)

dat_createHLLH$HLLH_mix = ifelse(dat_createHLLH$create_pairs_HL == "LH" & dat_createHLLH$create_pairs_LH == "HL",
                                 1,0)
dat_createHLLH$HLLH_seg = ifelse(dat_createHLLH$create_pairs_HL == "HL" & dat_createHLLH$create_pairs_LH == "LH",
                                 1,0)

#create tables with frequencies
table_HHLL_mix <- table(dat_createHHLL$type[dat_createHHLL$HHLL_mix == 1]) / (table(dat_createHHLL$type[dat_createHHLL$HHLL_mix == 1]) + table(dat_createHHLL$type[dat_createHHLL$HHLL_mix == 0])) * 100
table_HHLL_seg <- table(dat_createHHLL$type[dat_createHHLL$HHLL_seg == 1]) / (table(dat_createHHLL$type[dat_createHHLL$HHLL_seg == 1]) + table(dat_createHHLL$type[dat_createHHLL$HHLL_seg == 0])) * 100
table_HLLH_mix <- table(dat_createHLLH$type[dat_createHLLH$HLLH_mix == 1]) / (table(dat_createHLLH$type[dat_createHLLH$HLLH_mix == 1]) + table(dat_createHLLH$type[dat_createHLLH$HLLH_mix == 0])) * 100
table_HLLH_seg <- table(dat_createHLLH$type[dat_createHLLH$HLLH_seg == 1]) / (table(dat_createHLLH$type[dat_createHLLH$HLLH_seg == 1]) + table(dat_createHLLH$type[dat_createHLLH$HLLH_seg == 0])) * 100

#create data
df_HHLL_mix <- data.frame(Type = rownames(table_HHLL_mix), Values = as.vector(table_HHLL_mix), Table_Name = "HHLL_mix")
df_HHLL_seg <- data.frame(Type = rownames(table_HHLL_seg), Values = as.vector(table_HHLL_seg), Table_Name = "HHLL_seg")
df_HLLH_mix <- data.frame(Type = rownames(table_HLLH_mix), Values = as.vector(table_HLLH_mix), Table_Name = "HLLH_mix")
df_HLLH_seg <- data.frame(Type = rownames(table_HLLH_seg), Values = as.vector(table_HLLH_seg), Table_Name = "HLLH_seg")

#combine tables
combined_tables <- rbind(df_HHLL_mix, df_HHLL_seg, df_HLLH_mix, df_HLLH_seg)
combined_tables <- combined_tables %>%
  separate(Table_Name, into = c("Pair", "Choice"), sep = "_")

#calculate 'other' values
between_values <- combined_tables %>%
  group_by(Pair, Type) %>%
  summarise(Sum_Values = sum(Values), .groups = 'drop') %>%
  mutate(Between = 100 - Sum_Values) %>%
  dplyr::select(Pair, Type, Between) %>%
  mutate(Choice = "Between") %>%
  filter(!is.na(Between))

#combine 'other' with segregation and mix data
combined_tables <- bind_rows(combined_tables, between_values)

#replace non-NA other values
combined_tables <- combined_tables %>%
  mutate(Values = ifelse(is.na(Values) & Choice == "Between", Between, Values)) %>%
  dplyr::select(-Between)

combined_tables$Type = factor(combined_tables$Type, levels = c("TP", "HH", "HL", "LH", "LL"))
combined_tables$Choice = ifelse(combined_tables$Choice == "Between", "other", combined_tables$Choice)
combined_tables$Choice = factor(combined_tables$Choice, levels = c("other", "mix", "seg"))

table(dat_createHHLL$type)
table(dat_createHLLH$type)
combined_tables[combined_tables$Choice == "other",]
((21.73913 * 46) + (31.48148 * 54)) / 100
((43.13725 * 51) + (30.30303 * 33) + (45.23810 * 42) + (28.57143 * 42) + (34.69388 * 49) + (22.38806 * 67) + (46.55172 * 58) + (29.31034 * 58)) / 400

#plot
ggplot(combined_tables, aes(x = Type, y = Values, fill = Choice)) +
  geom_bar(stat = "identity", position = "stack", width = 0.8) +
  facet_wrap(~ Pair, scales = "free", nrow = 1) +
  theme_bw() +
  theme(
    text = element_text(size = 18),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    legend.position = "top"
  ) +
  ylim(0, 100) +
  ylab("frequency (%)") +
  xlab("type") +
  scale_fill_manual(values = c(HLcol, LLcol, HHcol)) +
  labs(fill = " ")

#end

###################################################################################################################################

### Figure 3

## Panel A

#calculate average relative cooperation based on type and partner type
agg <- aggregate(dat_fair$coop_rel, by=list(dat_fair$type, dat_fair$pair, dat_fair$type_in_pair), agg_switch_na.rm)
aggse <- aggregate(dat_fair$coop_rel, by=list(dat_fair$type, dat_fair$pair, dat_fair$type_in_pair), agg_switch_sem)
agg$SE = aggse$x

#plot
ggplot(agg[agg$Group.1 == "TP",], aes(x = Group.2, y = x, fill = Group.3)) +
  geom_bar(position="dodge", stat="identity", colour = "black", width = 0.8) +
  facet_wrap(~Group.3, ncol = 10, scales = "free_x") +  # You can adjust the number of columns as needed
  theme_bw() + theme(text  = element_text(size = 18), panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  theme(legend.position = "top") +  # Adjust the legend position as needed
  scale_fill_manual(values=c(HHcol,HLcol, LHcol, LLcol)) +
  ylim(0,100) +  ylab("cooperation (%)") + labs(fill = " ") +
  geom_errorbar(aes(ymin=x-SE, ymax=x+SE), width=.2,
                position=position_dodge(.78))

#end



## Panel B

#calculate average relative earnings based on type and partner type
agg <- aggregate(dat_fair$earn_rel, by=list(dat_fair$type, dat_fair$pair, dat_fair$type_in_pair), agg_switch_na.rm)
aggse <- aggregate(dat_fair$earn_rel, by=list(dat_fair$type, dat_fair$pair, dat_fair$type_in_pair), agg_switch_sem)
agg$SE = aggse$x

#calculate how much types should relatively receive if redistribution would be based on equality or merit
agg$equal = 50
agg$merit = NA
agg[agg$Group.2 == "HHHH" & agg$Group.3 == "HH",]$merit = 50
agg[agg$Group.2 == "HHHL" & agg$Group.3 == "HH",]$merit = (75*1.7) / (75*1.7 + 75*1.3) * 100
agg[agg$Group.2 == "HHHL" & agg$Group.3 == "HL",]$merit = (75*1.3) / (75*1.7 + 75*1.3) * 100
agg[agg$Group.2 == "HHLH" & agg$Group.3 == "HH",]$merit = (75*1.7) / (75*1.7 + 25*1.7) * 100
agg[agg$Group.2 == "HHLH" & agg$Group.3 == "LH",]$merit = (25*1.7) / (75*1.7 + 25*1.7) * 100
agg[agg$Group.2 == "HHLL" & agg$Group.3 == "HH",]$merit = (75*1.7) / (75*1.7 + 25*1.3) * 100
agg[agg$Group.2 == "HHLL" & agg$Group.3 == "LL",]$merit = (25*1.3) / (75*1.7 + 25*1.3) * 100
agg[agg$Group.2 == "HLHL" & agg$Group.3 == "HL",]$merit = 50
agg[agg$Group.2 == "HLLH" & agg$Group.3 == "HL",]$merit = (75*1.3) / (75*1.3 + 25*1.7) * 100
agg[agg$Group.2 == "HLLH" & agg$Group.3 == "LH",]$merit = (25*1.7) / (75*1.3 + 25*1.7) * 100
agg[agg$Group.2 == "HLLL" & agg$Group.3 == "HL",]$merit = (75*1.3) / (75*1.3 + 25*1.3) * 100
agg[agg$Group.2 == "HLLL" & agg$Group.3 == "LL",]$merit = (25*1.3) / (75*1.3 + 25*1.3) * 100
agg[agg$Group.2 == "LHLH" & agg$Group.3 == "LH",]$merit = 50
agg[agg$Group.2 == "LHLL" & agg$Group.3 == "LH",]$merit = (25*1.7) / (25*1.7 + 25*1.3) * 100
agg[agg$Group.2 == "LHLL" & agg$Group.3 == "LL",]$merit = (25*1.3) / (25*1.7 + 25*1.3) * 100
agg[agg$Group.2 == "LLLL" & agg$Group.3 == "LL",]$merit = 50

#only select pairs with non-similar types
agg2 = agg[agg$Group.1 == "TP" & agg$Group.2 != "HHHH" & agg$Group.2 != "HLHL" & agg$Group.2 != "LHLH" & agg$Group.2 != "LLLL", ]

#plot
ggplot(agg2, aes(x = Group.3, y = x, color = Group.3)) +
  geom_bar(position = "dodge", stat = "identity", fill = NA, color = c(HHcol, HLcol, HHcol, LHcol, HHcol, LLcol, HLcol, LHcol, HLcol, LLcol, LHcol, LLcol), size = 1, width = 0.8) +
  facet_wrap(~ Group.2, scales = "free", nrow = 1) +  # Faceting by pair
  theme_bw() +
  theme(
    text = element_text(size = 18),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    legend.position = "top"
  ) +
  scale_color_manual(values = c("HH" = HHcol, "HL" = HLcol, "LH" = LHcol, "LL" = LLcol)) +
  ylim(0, 100) +
  ylab("earnings (%)") +
  xlab("type") +
  labs(color = " ") +
  geom_errorbar(aes(ymin = x - SE, ymax = x + SE), width = 0.2, position = position_dodge(0.78)) +
  geom_hline(yintercept = agg2$equal, linetype = "dashed", color = "black", size = 1) +
  geom_hline(data = subset(agg2, !is.na(merit)), aes(yintercept = merit, color = Group.3), linetype = "dashed", size = 1)

#end

