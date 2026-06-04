#packages
library(readxl)
library(dplyr)
library(tidyr)

#load dat_raw
raw <- read.csv("snijderDecisionmakersSelfservinglyNavigate2024/scripts/process_data/raw.csv")
#View(raw)

##########################################################################################

#attention Checks
table(raw$AC1)
#second attention check was too difficult
table(raw$AC2_1)
table(raw$AC2_2)
table(raw$AC3)

#response time
raw$Duration..in.seconds.

#faster than 15 minutes
table(as.numeric(raw$Duration..in.seconds.) < 900)

#faster than 20 minutes
table(as.numeric(raw$Duration..in.seconds.) < 1200)

##########################################################################################

dat = data.frame(matrix(nrow = nrow(raw), ncol = 0))

dat$pp = raw$ResponseId
dat$ProlificID = raw$ProlificID

dat$type = raw$role_self
dat$type = ifelse(dat$type == 'Type 1', 'HH', dat$type)
dat$type = ifelse(dat$type == 'Type 2', 'HL', dat$type)
dat$type = ifelse(dat$type == 'Type 3', 'LH', dat$type)
dat$type = ifelse(dat$type == 'Type 4', 'LL', dat$type)
dat$type = ifelse(dat$type == 'thirdparty', 'TP', dat$type)
dat$type

dat$endowment = NA
dat$endowment = ifelse(dat$type == 'HH' | dat$type == 'HL', 75, dat$endowment)
dat$endowment = ifelse(dat$type == 'LH' | dat$type == 'LL', 25, dat$endowment)
dat$endowment = ifelse(dat$type == 'TP', 0, dat$endowment)

dat$productivity = NA
dat$productivity = ifelse(dat$type == 'HH' | dat$type == 'LH', 1.7, dat$productivity)
dat$productivity = ifelse(dat$type == 'HL' | dat$type == 'LL', 1.3, dat$productivity)
dat$productivity = ifelse(dat$type == 'TP', 0, dat$productivity)

dat$svo_angle = raw$svo_angle
dat$svo_category = raw$svo_category
dat$svo_totalself = raw$svo_totalself
dat$svo_totalother = raw$svo_totalother

##########################################################################################

dat$pref_1 = raw$pref_1
dat$pref_2 = raw$pref_2
dat$pref_3 = raw$pref_3
dat$pref_4 = raw$pref_4

dat$pref_1 = ifelse(dat$type == "TP", NA, dat$pref_1)
dat$pref_2 = ifelse(dat$type == "TP", NA, dat$pref_2)
dat$pref_3 = ifelse(dat$type == "TP", NA, dat$pref_3)
dat$pref_4 = ifelse(dat$type == "TP", NA, dat$pref_4)

dat$coop_HH = raw$coop_HH
dat$coop_HL = raw$coop_HL
dat$coop_LH = raw$coop_LH
dat$coop_LL = raw$coop_LL

dat$coop_HH = ifelse(dat$type == "TP", NA, dat$coop_HH)
dat$coop_HL = ifelse(dat$type == "TP", NA, dat$coop_HL)
dat$coop_LH = ifelse(dat$type == "TP", NA, dat$coop_LH)
dat$coop_LL = ifelse(dat$type == "TP", NA, dat$coop_LL)

dat$belief_HH = raw$belief_HH
dat$belief_HL = raw$belief_HL
dat$belief_LH = raw$belief_LH
dat$belief_LL = raw$belief_LL

dat$belief_HH = ifelse(dat$type == "TP", NA, dat$belief_HH)
dat$belief_HL = ifelse(dat$type == "TP", NA, dat$belief_HL)
dat$belief_LH = ifelse(dat$type == "TP", NA, dat$belief_LH)
dat$belief_LL = ifelse(dat$type == "TP", NA, dat$belief_LL)

##########################################################################################

dat$create_types = ifelse(raw$create_type_1 == "Type A" & raw$create_type_3 == "Type A" |
                            raw$create_type_1 == "Type B" & raw$create_type_3 == "Type B",
                          "HH-LL", "HL-LH")

dat$create_types_MC = raw$createtype_MC
dat$create_types_MC = ifelse(dat$create_types_MC == "Inequality - I wanted to reduce inequality between Types", "Inequality", dat$create_types_MC)
dat$create_types_MC = ifelse(dat$create_types_MC == "Maximal benefit - I wanted to maximize (joint) possible outcomes", "Welfare", dat$create_types_MC)
dat$create_types_MC = ifelse(dat$create_types_MC == "Similarity - I matched Incomes and Multipliers based on similarity (i.e., high to high and low to low)", "Similarity", dat$create_types_MC)
dat$create_types_MC = ifelse(dat$create_types_MC == "Random - I randomly assigned Incomes and Multipliers", "Random", dat$create_types_MC)
dat$create_types_MC
dat$create_types_MC_other = raw$createtype_MC_9_TEXT

##########################################################################################

dat$create_pairs_HH = NA
dat$create_pairs_HL = NA
dat$create_pairs_LH = NA
dat$create_pairs_LL = NA

dat$create_pairs_HH = ifelse(raw$role_self == 'Type 1', raw$createpair_1, dat$create_pairs_HH)
dat$create_pairs_HH = ifelse(raw$role_self == 'Type 2', raw$createpairs_1, dat$create_pairs_HH)
dat$create_pairs_HH = ifelse(raw$role_self == 'Type 3', raw$createpair_1.1, dat$create_pairs_HH)
dat$create_pairs_HH = ifelse(raw$role_self == 'Type 4', raw$createpair_1.2, dat$create_pairs_HH)
dat$create_pairs_HH = ifelse(raw$role_self == 'thirdparty', raw$THIRDcreatepair_1, dat$create_pairs_HH)
dat$create_pairs_HH

dat$create_pairs_HL = ifelse(raw$role_self == 'Type 1', raw$createpair_2, dat$create_pairs_HL)
dat$create_pairs_HL = ifelse(raw$role_self == 'Type 2', raw$createpairs_2, dat$create_pairs_HL)
dat$create_pairs_HL = ifelse(raw$role_self == 'Type 3', raw$createpair_2.1, dat$create_pairs_HL)
dat$create_pairs_HL = ifelse(raw$role_self == 'Type 4', raw$createpair_2.2, dat$create_pairs_HL)
dat$create_pairs_HL = ifelse(raw$role_self == 'thirdparty', raw$THIRDcreatepair_2, dat$create_pairs_HL)
dat$create_pairs_HL

dat$create_pairs_LH = ifelse(raw$role_self == 'Type 1', raw$createpair_3, dat$create_pairs_LH)
dat$create_pairs_LH = ifelse(raw$role_self == 'Type 2', raw$createpairs_3, dat$create_pairs_LH)
dat$create_pairs_LH = ifelse(raw$role_self == 'Type 3', raw$createpair_3.1, dat$create_pairs_LH)
dat$create_pairs_LH = ifelse(raw$role_self == 'Type 4', raw$createpair_3.2, dat$create_pairs_LH)
dat$create_pairs_LH = ifelse(raw$role_self == 'thirdparty', raw$THIRDcreatepair_3, dat$create_pairs_LH)
dat$create_pairs_LH

dat$create_pairs_LL = ifelse(raw$role_self == 'Type 1', raw$createpair_4, dat$create_pairs_LL)
dat$create_pairs_LL = ifelse(raw$role_self == 'Type 2', raw$createpairs_4, dat$create_pairs_LL)
dat$create_pairs_LL = ifelse(raw$role_self == 'Type 3', raw$createpair_4.1, dat$create_pairs_LL)
dat$create_pairs_LL = ifelse(raw$role_self == 'Type 4', raw$createpair_4.2, dat$create_pairs_LL)
dat$create_pairs_LL = ifelse(raw$role_self == 'thirdparty', raw$THIRDcreatepair_4, dat$create_pairs_LL)
dat$create_pairs_LL

lookup_table <- c("Pair A\n " = "HH", "Pair B\n " = "HL", "Pair C\n " = "LH", "Pair D\n " = "LL")
columns_to_modify <- c("create_pairs_HH", "create_pairs_HL", "create_pairs_LH", "create_pairs_LL")

for (col in columns_to_modify) {
  dat[[col]] <- lookup_table[dat[[col]]]
}

dat$create_pairs_MC = raw$createpair_MC.
dat$create_pairs_MC = ifelse(dat$create_pairs_MC == "Inequality - I wanted to reduce inequality between Types", "Inequality", dat$create_pairs_MC)
dat$create_pairs_MC = ifelse(dat$create_pairs_MC == "Maximal benefit - I wanted to maximize possible (joint) outcomes in some pairs", "Welfare", dat$create_pairs_MC)
dat$create_pairs_MC = ifelse(dat$create_pairs_MC == "Similarity - I matched Types based on similarity (i.e., high to high and low to low)", "Similarity", dat$create_pairs_MC)
dat$create_pairs_MC = ifelse(dat$create_pairs_MC == "Random - I randomly assigned Types to pairs", "Random", dat$create_pairs_MC)
dat$create_pairs_MC
dat$create_pairs_MC_other = raw$createpair_MC._9_TEXT

##########################################################################################

dat$fair_con_HHHH_HH = as.numeric(raw$Con_HHHH_1_1)
dat$fair_con_HHHH_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q363_1_1), dat$fair_con_HHHH_HH)

dat$fair_con_HHHL_HH = as.numeric(raw$Con_HHHL_1_1)
dat$fair_con_HHHL_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q364_1_1), dat$fair_con_HHHL_HH)
dat$fair_con_HHHL_HH = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q365_1_1), dat$fair_con_HHHL_HH)

dat$fair_con_HHHL_HL = as.numeric(raw$Con_HHHL_2_1)
dat$fair_con_HHHL_HL = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q364_2_1), dat$fair_con_HHHL_HL)
dat$fair_con_HHHL_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q365_2_1), dat$fair_con_HHHL_HL)

dat$fair_con_HHLH_HH = as.numeric(raw$Con_HHLH_1_1)
dat$fair_con_HHLH_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q366_1_1), dat$fair_con_HHLH_HH)
dat$fair_con_HHLH_HH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q367_1_1), dat$fair_con_HHLH_HH)

dat$fair_con_HHLH_LH = as.numeric(raw$Con_HHLH_2_1)
dat$fair_con_HHLH_LH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q366_2_1), dat$fair_con_HHLH_LH)
dat$fair_con_HHLH_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q367_2_1), dat$fair_con_HHLH_LH)

dat$fair_con_HHLL_HH = as.numeric(raw$Con_HHLL_1_1)
dat$fair_con_HHLL_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q368_1_1), dat$fair_con_HHLL_HH)
dat$fair_con_HHLL_HH = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q369_1_1), dat$fair_con_HHLL_HH)

dat$fair_con_HHLL_LL = as.numeric(raw$Con_HHLL_2_1)
dat$fair_con_HHLL_LL = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q368_2_1), dat$fair_con_HHLL_LL)
dat$fair_con_HHLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q369_2_1), dat$fair_con_HHLL_LL)

dat$fair_con_HLHL_HL = as.numeric(raw$Con_HLHL_1_1)
dat$fair_con_HLHL_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q370_1_1), dat$fair_con_HLHL_HL)

dat$fair_con_HLLH_HL = as.numeric(raw$Con_HLLH_1_1)
dat$fair_con_HLLH_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q371_1_1), dat$fair_con_HLLH_HL)
dat$fair_con_HLLH_HL = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q372_1_1), dat$fair_con_HLLH_HL)

dat$fair_con_HLLH_LH = as.numeric(raw$Con_HLLH_2_1)
dat$fair_con_HLLH_LH = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q371_2_1), dat$fair_con_HLLH_LH)
dat$fair_con_HLLH_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q372_2_1), dat$fair_con_HLLH_LH)

dat$fair_con_HLLL_HL = as.numeric(raw$Con_HLLL_1_1)
dat$fair_con_HLLL_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q373_1_1), dat$fair_con_HLLL_HL)
dat$fair_con_HLLL_HL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q374_1_1), dat$fair_con_HLLL_HL)

dat$fair_con_HLLL_LL = as.numeric(raw$Con_HLLL_2_1)
dat$fair_con_HLLL_LL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q373_2_1), dat$fair_con_HLLL_LL)
dat$fair_con_HLLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q374_2_1), dat$fair_con_HLLL_LL)

dat$fair_con_LHLH_LH = as.numeric(raw$Con_LHLH_1_1)
dat$fair_con_LHLH_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q375_1_1), dat$fair_con_LHLH_LH)

dat$fair_con_LHLL_LH = as.numeric(raw$Con_LHLL_1_1)
dat$fair_con_LHLL_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q376_1_1), dat$fair_con_LHLL_LH)
dat$fair_con_LHLL_LH = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q377_1_1), dat$fair_con_LHLL_LH)

dat$fair_con_LHLL_LL = as.numeric(raw$Con_LHLL_2_1)
dat$fair_con_LHLL_LL = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q376_2_1), dat$fair_con_LHLL_LL)
dat$fair_con_LHLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q377_2_1), dat$fair_con_LHLL_LL)

dat$fair_con_LLLL_LL = as.numeric(raw$Con_LLLL_1_1)
dat$fair_con_LLLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q378_1_1), dat$fair_con_LLLL_LL)

dat$faircoop_MC = raw$faircoop_MC
dat$faircoop_MC = ifelse(dat$faircoop_MC == "Inequality - I wanted to reduce inequality between Types", "Inequality", dat$faircoop_MC)
dat$faircoop_MC = ifelse(dat$faircoop_MC == "Maximal benefit - I wanted to maximize possible (joint) outcomes in some pairs", "Welfare", dat$faircoop_MC)
dat$faircoop_MC = ifelse(dat$faircoop_MC == "Similarity - I matched contributions", "Similarity", dat$faircoop_MC)
dat$faircoop_MC = ifelse(dat$faircoop_MC == "Random - I randomly assigned contributions", "Random", dat$faircoop_MC)
dat$faircoop_MC
dat$faircoop_MC_other = raw$faircoop_MC_9_TEXT

##########################################################################################

dat$fair_earn_HHHH_HH_1 = as.numeric(raw$earn_HHHH_1_1)
dat$fair_earn_HHHH_HH_1 = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q379_1_1), dat$fair_earn_HHHH_HH_1)

dat$fair_earn_HHHH_HH_2 = as.numeric(raw$earn_HHHH_2_1)
dat$fair_earn_HHHH_HH_2 = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q379_2_1), dat$fair_earn_HHHH_HH_2)

dat$fair_earn_HHHL_HH = as.numeric(raw$earn_HHHL_1_1)
dat$fair_earn_HHHL_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q380_1_1), dat$fair_earn_HHHL_HH)
dat$fair_earn_HHHL_HH = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q381_1_1), dat$fair_earn_HHHL_HH)

dat$fair_earn_HHHL_HL = as.numeric(raw$earn_HHHL_2_1)
dat$fair_earn_HHHL_HL = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q380_2_1), dat$fair_earn_HHHL_HL)
dat$fair_earn_HHHL_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q381_2_1), dat$fair_earn_HHHL_HL)

dat$fair_earn_HHLH_HH = as.numeric(raw$earn_HHLH_1_1)
dat$fair_earn_HHLH_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q382_1_1), dat$fair_earn_HHLH_HH)
dat$fair_earn_HHLH_HH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q383_1_1), dat$fair_earn_HHLH_HH)

dat$fair_earn_HHLH_LH = as.numeric(raw$earn_HHLH_2_1)
dat$fair_earn_HHLH_LH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q382_2_1), dat$fair_earn_HHLH_LH)
dat$fair_earn_HHLH_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q383_2_1), dat$fair_earn_HHLH_LH)

dat$fair_earn_HHLL_HH = as.numeric(raw$earn_HHLL_1_1)
dat$fair_earn_HHLL_HH = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q384_1_1), dat$fair_earn_HHLL_HH)
dat$fair_earn_HHLL_HH = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q385_1_1), dat$fair_earn_HHLL_HH)

dat$fair_earn_HHLL_LL = as.numeric(raw$earn_HHLL_2_1)
dat$fair_earn_HHLL_LL = ifelse(raw$role_self == 'Type 1', as.numeric(raw$Q384_2_1), dat$fair_earn_HHLL_LL)
dat$fair_earn_HHLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q385_2_1), dat$fair_earn_HHLL_LL)

dat$fair_earn_HLHL_HL_1 = as.numeric(raw$earn_HLHL_1_1)
dat$fair_earn_HLHL_HL_1 = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q386_1_1), dat$fair_earn_HLHL_HL_1)

dat$fair_earn_HLHL_HL_2 = as.numeric(raw$earn_HLHL_2_1)
dat$fair_earn_HLHL_HL_2 = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q386_2_1), dat$fair_earn_HLHL_HL_2)

dat$fair_earn_HLLH_HL = as.numeric(raw$earn_HLLH_1_1)
dat$fair_earn_HLLH_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q387_1_1), dat$fair_earn_HLLH_HL)
dat$fair_earn_HLLH_HL = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q388_1_1), dat$fair_earn_HLLH_HL)

dat$fair_earn_HLLH_LH = as.numeric(raw$earn_HLLH_2_1)
dat$fair_earn_HLLH_LH = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q387_2_1), dat$fair_earn_HLLH_LH)
dat$fair_earn_HLLH_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q388_2_1), dat$fair_earn_HLLH_LH)

dat$fair_earn_HLLL_HL = as.numeric(raw$earn_HLLL_1_1)
dat$fair_earn_HLLL_HL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q389_1_1), dat$fair_earn_HLLL_HL)
dat$fair_earn_HLLL_HL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q390_1_1), dat$fair_earn_HLLL_HL)

dat$fair_earn_HLLL_LL = as.numeric(raw$earn_HLLL_2_1)
dat$fair_earn_HLLL_LL = ifelse(raw$role_self == 'Type 2', as.numeric(raw$Q389_2_1), dat$fair_earn_HLLL_LL)
dat$fair_earn_HLLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q390_2_1), dat$fair_earn_HLLL_LL)

dat$fair_earn_LHLH_LH_1 = as.numeric(raw$earn_LHLH_1_1)
dat$fair_earn_LHLH_LH_1 = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q391_1_1), dat$fair_earn_LHLH_LH_1)

dat$fair_earn_LHLH_LH_2 = as.numeric(raw$earn_LHLH_2_1)
dat$fair_earn_LHLH_LH_2 = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q391_2_1), dat$fair_earn_LHLH_LH_2)

dat$fair_earn_LHLL_LH = as.numeric(raw$earn_LHLL_1_1)
dat$fair_earn_LHLL_LH = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q392_1_1), dat$fair_earn_LHLL_LH)
dat$fair_earn_LHLL_LH = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q393_1_1), dat$fair_earn_LHLL_LH)

dat$fair_earn_LHLL_LL = as.numeric(raw$earn_LHLL_2_1)
dat$fair_earn_LHLL_LL = ifelse(raw$role_self == 'Type 3', as.numeric(raw$Q392_2_1), dat$fair_earn_LHLL_LL)
dat$fair_earn_LHLL_LL = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q393_2_1), dat$fair_earn_LHLL_LL)

dat$fair_earn_LLLL_LL_1 = as.numeric(raw$earn_LLLL_1_1)
dat$fair_earn_LLLL_LL_1 = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q394_1_1), dat$fair_earn_LLLL_LL_1)

dat$fair_earn_LLLL_LL_2 = as.numeric(raw$earn_LLLL_2_1)
dat$fair_earn_LLLL_LL_2 = ifelse(raw$role_self == 'Type 4', as.numeric(raw$Q394_2_1), dat$fair_earn_LLLL_LL_2)

dat$fairearn_MC = raw$fairearn_MC
dat$fairearn_MC = ifelse(dat$fairearn_MC == "Inequality - I wanted to reduce inequality between Types", "Inequality", dat$fairearn_MC)
dat$fairearn_MC = ifelse(dat$fairearn_MC == "Maximal benefit - I wanted to assign more earnings to Types that maximized possible (joint) outcomes", "Welfare", dat$fairearn_MC)
dat$fairearn_MC = ifelse(dat$fairearn_MC == "Similarity - I wanted both Types to earn the same amount", "Similarity", dat$fairearn_MC)
dat$fairearn_MC = ifelse(dat$fairearn_MC == "Random - I randomly assigned earnings to Types" , "Random", dat$fairearn_MC)
dat$fairearn_MC
dat$fairearn_MC_other = raw$fairearn_MC_9_TEXT

##########################################################################################

dat$inequality_beliefs1_1 = raw$Beliefs1_1
dat$inequality_beliefs1_2 = raw$Beliefs1_2
dat$inequality_beliefs1_3 = raw$Beliefs1_3
dat$inequality_beliefs1_4 = raw$Beliefs1_4

dat$inequality_beliefs2_1 = raw$Beliefs2_1
dat$inequality_beliefs2_2 = raw$Beliefs2_2
dat$inequality_beliefs2_3 = raw$Beliefs2_3
dat$inequality_beliefs2_4 = raw$Beliefs2_4
dat$inequality_beliefs2_5 = raw$Beliefs2_5

dat$inequality_attitudes_1 = raw$Attitudes_1
dat$inequality_attitudes_2 = raw$Attitudes_2

##########################################################################################

dat$gender = raw$Gender
dat$age = raw$Age
dat$country = raw$Country
dat$education = raw$Education
dat$political_orientation = raw$political_orientation
dat$social_ideology = raw$social_ideology
dat$economic_ideology = raw$economic_ideology

#View(dat)

##########################################################################################

## Create long data frame

#create relative fair contributions
dat$fair_con_HHHH_HH_rel = dat$fair_con_HHHH_HH / 75 * 100
dat$fair_con_HHHL_HH_rel = dat$fair_con_HHHL_HH / 75 * 100
dat$fair_con_HHHL_HL_rel = dat$fair_con_HHHL_HL / 75 * 100
dat$fair_con_HHLH_HH_rel = dat$fair_con_HHLH_HH / 75 * 100
dat$fair_con_HHLH_LH_rel = dat$fair_con_HHLH_LH / 25 * 100
dat$fair_con_HHLL_HH_rel = dat$fair_con_HHLL_HH / 75 * 100
dat$fair_con_HHLL_LL_rel = dat$fair_con_HHLL_LL / 25 * 100
dat$fair_con_HLHL_HL_rel = dat$fair_con_HLHL_HL / 75 * 100
dat$fair_con_HLLH_HL_rel = dat$fair_con_HLLH_HL / 75 * 100
dat$fair_con_HLLH_LH_rel = dat$fair_con_HLLH_LH / 25 * 100
dat$fair_con_HLLL_HL_rel = dat$fair_con_HLLL_HL / 75 * 100
dat$fair_con_HLLL_LL_rel = dat$fair_con_HLLL_LL / 25 * 100
dat$fair_con_LHLH_LH_rel = dat$fair_con_LHLH_LH / 25 * 100
dat$fair_con_LHLL_LH_rel = dat$fair_con_LHLL_LH / 25 * 100
dat$fair_con_LHLL_LL_rel = dat$fair_con_LHLL_LL / 25 * 100
dat$fair_con_LLLL_LL_rel = dat$fair_con_LLLL_LL / 25 * 100

#create relative fair earnings
dat$fair_earn_HHHH_HH_rel = dat$fair_earn_HHHH_HH_1 / ((75 * 1.7) + (75 * 1.7)) * 100
dat$fair_earn_HHHL_HH_rel = dat$fair_earn_HHHL_HH / ((75 * 1.7) + (75 * 1.3)) * 100
dat$fair_earn_HHHL_HL_rel = dat$fair_earn_HHHL_HL / ((75 * 1.7) + (75 * 1.3)) * 100
dat$fair_earn_HHLH_HH_rel = dat$fair_earn_HHLH_HH / ((75 * 1.7) + (25 * 1.7)) * 100
dat$fair_earn_HHLH_LH_rel = dat$fair_earn_HHLH_LH / ((75 * 1.7) + (25 * 1.7)) * 100
dat$fair_earn_HHLL_HH_rel = dat$fair_earn_HHLL_HH / ((75 * 1.7) + (25 * 1.3)) * 100
dat$fair_earn_HHLL_LL_rel = dat$fair_earn_HHLL_LL / ((75 * 1.7) + (25 * 1.3)) * 100
dat$fair_earn_HLHL_HL_rel = dat$fair_earn_HLHL_HL_1 / ((75 * 1.3) + (75 * 1.3)) * 100
dat$fair_earn_HLLH_HL_rel = dat$fair_earn_HLLH_HL / ((75 * 1.3) + (25 * 1.7)) * 100
dat$fair_earn_HLLH_LH_rel = dat$fair_earn_HLLH_LH / ((75 * 1.3) + (25 * 1.7)) * 100
dat$fair_earn_HLLL_HL_rel = dat$fair_earn_HLLL_HL / ((75 * 1.3) + (25 * 1.3)) * 100
dat$fair_earn_HLLL_LL_rel = dat$fair_earn_HLLL_LL / ((75 * 1.3) + (25 * 1.3)) * 100
dat$fair_earn_LHLH_LH_rel = dat$fair_earn_LHLH_LH_1 / ((25 * 1.7) + (25 * 1.7)) * 100
dat$fair_earn_LHLL_LH_rel = dat$fair_earn_LHLL_LH / ((25 * 1.7) + (25 * 1.3)) * 100
dat$fair_earn_LHLL_LL_rel = dat$fair_earn_LHLL_LL / ((25 * 1.7) + (25 * 1.3)) * 100
dat$fair_earn_LLLL_LL_rel = dat$fair_earn_LLLL_LL_1 / ((25 * 1.3) + (25 * 1.3)) * 100

#in my country, one of the main reasons for the rich being richer than the poor is that the rich have worked harder in life than the poor.
dat$inequality_beliefs1_1
#in my country, one of the main reasons for the rich being richer than the poor is that the rich have had more luck in life than the poor.
dat$inequality_beliefs1_2
#in my country, one of the main reasons for the rich being richer than the poor is that the rich were born with greater abilities than the poor.
dat$inequality_beliefs1_3
#in my country, if the government increases the taxes that the rich have to pay, the rich will work less and invest less.
dat$inequality_beliefs1_4

#in my country, one of the main reasons for the rich being richer than the poor is that the rich have been more selfish in life than the poor.
dat$inequality_beliefs2_1
#in my country, one of the main reasons for the rich being richer than the poor is that the rich are more willing than the poor to give up something today to benefit from that in the future.
dat$inequality_beliefs2_2
#in my country, one of the main reasons for the rich being richer than the poor is that the rich are more willing to take economic risks than the poor.
dat$inequality_beliefs2_3
#in my country, one of the main reasons for the rich being richer than the poor is that the rich have parents or other family members that provided them with greater opportunities than the poor.
dat$inequality_beliefs2_4
#in my country, one of the main reasons for the rich being richer than the poor is that the rich have been more involved in illegal activities than the poor.
dat$inequality_beliefs2_5

#in my country, the economic differences between the rich and poor are unfair.
dat$inequality_attitudes_1
#in my country, the national government should aim to reduce the economic differences between the rich and the poor.
dat$inequality_attitudes_2

#define the mapping from labels to numeric values
label_to_num <- c(
  "strongly disagree" = 1,
  "disagree somewhat" = 2,
  "neither agree\nnor disagree" = 3,
  "agree somewhat" = 4,
  "strongly agree" = 5
)

#create a new column to store the numeric values
dat$inequality_beliefs1_1_num <- NA
dat$inequality_beliefs1_2_num <- NA
dat$inequality_beliefs1_3_num <- NA
dat$inequality_beliefs1_4_num <- NA

dat$inequality_beliefs2_1_num <- NA
dat$inequality_beliefs2_2_num <- NA
dat$inequality_beliefs2_3_num <- NA
dat$inequality_beliefs2_4_num <- NA
dat$inequality_beliefs2_5_num <- NA

dat$inequality_attitudes_1_num <- NA
dat$inequality_attitudes_2_num <- NA


#loop through the labels and assign numeric values for each variable
for (label in names(label_to_num)) {
  dat$inequality_beliefs1_1_num[dat$inequality_beliefs1_1 == label] <- label_to_num[label]
  dat$inequality_beliefs1_2_num[dat$inequality_beliefs1_2 == label] <- label_to_num[label]
  dat$inequality_beliefs1_3_num[dat$inequality_beliefs1_3 == label] <- label_to_num[label]
  dat$inequality_beliefs1_4_num[dat$inequality_beliefs1_4 == label] <- label_to_num[label]
  dat$inequality_beliefs2_1_num[dat$inequality_beliefs2_1 == label] <- label_to_num[label]
  dat$inequality_beliefs2_2_num[dat$inequality_beliefs2_2 == label] <- label_to_num[label]
  dat$inequality_beliefs2_3_num[dat$inequality_beliefs2_3 == label] <- label_to_num[label]
  dat$inequality_beliefs2_4_num[dat$inequality_beliefs2_4 == label] <- label_to_num[label]
  dat$inequality_beliefs2_5_num[dat$inequality_beliefs2_5 == label] <- label_to_num[label]
  dat$inequality_attitudes_1_num[dat$inequality_attitudes_1 == label] <- label_to_num[label]
  dat$inequality_attitudes_2_num[dat$inequality_attitudes_2 == label] <- label_to_num[label]
}

#create new variables for beliefs in luck and merit as causes for inequality
dat$merit = dat$inequality_beliefs1_1_num
dat$luck = dat$inequality_beliefs1_2_num

#create long data frame with actual cooperation and belief based on partner type
dat_long <- dat %>%
  pivot_longer(
    cols = starts_with("coop_") | starts_with("belief_"),
    names_to = c(".value", "partner_type"),
    names_sep = "_"
  ) %>%
  mutate(
    partner_type = case_when(
      partner_type == "HH" ~ "HH",
      partner_type == "HL" ~ "HL",
      partner_type == "LH" ~ "LH",
      partner_type == "LL" ~ "LL"
    )
  )

#create variable that indicates pair
dat_long$pair = NA
dat_long$pair = ifelse(dat_long$type == "HH" & dat_long$partner_type == "HH", "HH_HH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HH" & dat_long$partner_type == "HL", "HH_HL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HH" & dat_long$partner_type == "LH", "HH_LH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HH" & dat_long$partner_type == "LL", "HH_LL", dat_long$pair)

dat_long$pair = ifelse(dat_long$type == "HL" & dat_long$partner_type == "HH", "HH_HL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HL" & dat_long$partner_type == "HL", "HL_HL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HL" & dat_long$partner_type == "LH", "HL_LH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "HL" & dat_long$partner_type == "LL", "HL_LL", dat_long$pair)

dat_long$pair = ifelse(dat_long$type == "LH" & dat_long$partner_type == "HH", "HH_LH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LH" & dat_long$partner_type == "HL", "HL_LH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LH" & dat_long$partner_type == "LH", "LH_LH", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LH" & dat_long$partner_type == "LL", "LH_LL", dat_long$pair)

dat_long$pair = ifelse(dat_long$type == "LL" & dat_long$partner_type == "HH", "HH_LL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LL" & dat_long$partner_type == "HL", "HL_LL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LL" & dat_long$partner_type == "LH", "LH_LL", dat_long$pair)
dat_long$pair = ifelse(dat_long$type == "LL" & dat_long$partner_type == "LL", "LL_LL", dat_long$pair)

#create variable for relative cooperation, keep, and added to the public good
dat_long$coop_rel = dat_long$coop / dat_long$endowment * 100
dat_long$add_pgg = dat_long$coop * dat_long$productivity
dat_long$keep = dat_long$endowment - dat_long$coop

#create variable for earnings based on the average decision of the partner type
dat_long$earn = NA
dat_long[dat_long$type == "HH" & dat_long$partner_type == "HH",]$earn = dat_long[dat_long$type == "HH" & dat_long$partner_type == "HH",]$keep + ((dat_long[dat_long$type == "HH" & dat_long$partner_type == "HH",]$add_pgg + dat_long[dat_long$type == "HH" & dat_long$partner_type == "HH",]$add_pgg) / 2 )
dat_long[dat_long$type == "HH" & dat_long$partner_type == "HL",]$earn = dat_long[dat_long$type == "HH" & dat_long$partner_type == "HL",]$keep + ((dat_long[dat_long$type == "HH" & dat_long$partner_type == "HL",]$add_pgg + dat_long[dat_long$type == "HL" & dat_long$partner_type == "HH",]$add_pgg) / 2 )
dat_long[dat_long$type == "HH" & dat_long$partner_type == "LH",]$earn = dat_long[dat_long$type == "HH" & dat_long$partner_type == "LH",]$keep + ((dat_long[dat_long$type == "HH" & dat_long$partner_type == "LH",]$add_pgg + dat_long[dat_long$type == "LH" & dat_long$partner_type == "HH",]$add_pgg) / 2 )
dat_long[dat_long$type == "HH" & dat_long$partner_type == "LL",]$earn = dat_long[dat_long$type == "HH" & dat_long$partner_type == "LL",]$keep + ((dat_long[dat_long$type == "HH" & dat_long$partner_type == "LL",]$add_pgg + dat_long[dat_long$type == "LL" & dat_long$partner_type == "HH",]$add_pgg) / 2 )

dat_long[dat_long$type == "HL" & dat_long$partner_type == "HH",]$earn = dat_long[dat_long$type == "HL" & dat_long$partner_type == "HH",]$keep + ((dat_long[dat_long$type == "HL" & dat_long$partner_type == "HH",]$add_pgg + dat_long[dat_long$type == "HH" & dat_long$partner_type == "HL",]$add_pgg) / 2 )
dat_long[dat_long$type == "HL" & dat_long$partner_type == "HL",]$earn = dat_long[dat_long$type == "HL" & dat_long$partner_type == "HL",]$keep + ((dat_long[dat_long$type == "HL" & dat_long$partner_type == "HL",]$add_pgg + dat_long[dat_long$type == "HL" & dat_long$partner_type == "HL",]$add_pgg) / 2 )
dat_long[dat_long$type == "HL" & dat_long$partner_type == "LH",]$earn = dat_long[dat_long$type == "HL" & dat_long$partner_type == "LH",]$keep + ((dat_long[dat_long$type == "HL" & dat_long$partner_type == "LH",]$add_pgg + dat_long[dat_long$type == "LH" & dat_long$partner_type == "HL",]$add_pgg) / 2 )
dat_long[dat_long$type == "HL" & dat_long$partner_type == "LL",]$earn = dat_long[dat_long$type == "HL" & dat_long$partner_type == "LL",]$keep + ((dat_long[dat_long$type == "HL" & dat_long$partner_type == "LL",]$add_pgg + dat_long[dat_long$type == "LL" & dat_long$partner_type == "HL",]$add_pgg) / 2 )

dat_long[dat_long$type == "LH" & dat_long$partner_type == "HH",]$earn = dat_long[dat_long$type == "LH" & dat_long$partner_type == "HH",]$keep + ((dat_long[dat_long$type == "LH" & dat_long$partner_type == "HH",]$add_pgg + dat_long[dat_long$type == "HH" & dat_long$partner_type == "LH",]$add_pgg) / 2 )
dat_long[dat_long$type == "LH" & dat_long$partner_type == "HL",]$earn = dat_long[dat_long$type == "LH" & dat_long$partner_type == "HL",]$keep + ((dat_long[dat_long$type == "LH" & dat_long$partner_type == "HL",]$add_pgg + dat_long[dat_long$type == "HL" & dat_long$partner_type == "LH",]$add_pgg) / 2 )
dat_long[dat_long$type == "LH" & dat_long$partner_type == "LH",]$earn = dat_long[dat_long$type == "LH" & dat_long$partner_type == "LH",]$keep + ((dat_long[dat_long$type == "LH" & dat_long$partner_type == "LH",]$add_pgg + dat_long[dat_long$type == "LH" & dat_long$partner_type == "LH",]$add_pgg) / 2 )
dat_long[dat_long$type == "LH" & dat_long$partner_type == "LL",]$earn = dat_long[dat_long$type == "LH" & dat_long$partner_type == "LL",]$keep + ((dat_long[dat_long$type == "LH" & dat_long$partner_type == "LL",]$add_pgg + dat_long[dat_long$type == "LL" & dat_long$partner_type == "LH",]$add_pgg) / 2 )

dat_long[dat_long$type == "LL" & dat_long$partner_type == "HH",]$earn = dat_long[dat_long$type == "LL" & dat_long$partner_type == "HH",]$keep + ((dat_long[dat_long$type == "LL" & dat_long$partner_type == "HH",]$add_pgg + dat_long[dat_long$type == "HH" & dat_long$partner_type == "LL",]$add_pgg) / 2 )
dat_long[dat_long$type == "LL" & dat_long$partner_type == "HL",]$earn = dat_long[dat_long$type == "LL" & dat_long$partner_type == "HL",]$keep + ((dat_long[dat_long$type == "LL" & dat_long$partner_type == "HL",]$add_pgg + dat_long[dat_long$type == "HL" & dat_long$partner_type == "LL",]$add_pgg) / 2 )
dat_long[dat_long$type == "LL" & dat_long$partner_type == "LH",]$earn = dat_long[dat_long$type == "LL" & dat_long$partner_type == "LH",]$keep + ((dat_long[dat_long$type == "LL" & dat_long$partner_type == "LH",]$add_pgg + dat_long[dat_long$type == "LH" & dat_long$partner_type == "LL",]$add_pgg) / 2 )
dat_long[dat_long$type == "LL" & dat_long$partner_type == "LL",]$earn = dat_long[dat_long$type == "LL" & dat_long$partner_type == "LL",]$keep + ((dat_long[dat_long$type == "LL" & dat_long$partner_type == "LL",]$add_pgg + dat_long[dat_long$type == "LL" & dat_long$partner_type == "LL",]$add_pgg) / 2 )


#create data frame for fairness decisions
group_names_rel <- c(
  "HHHH_HH", "HHHL_HH", "HHHL_HL", "HHLH_HH",
  "HHLH_LH", "HHLL_HH", "HHLL_LL", "HLHL_HL",
  "HLLH_HL", "HLLH_LH", "HLLL_HL", "HLLL_LL",
  "LHLH_LH", "LHLL_LH", "LHLL_LL", "LLLL_LL"
)

type_names <- c("TP", "HH", "HL", "LH", "LL")

#create data frame to store means
dat_fair <- data.frame(matrix(ncol = 14, nrow = nrow(dat) * 16))
colnames(dat_fair) <- c("participant", "type", "svo_angle", "luck", "merit", "political_orientation", "economic_ideology", "social_ideology", "pair", "type_in_pair", "coop", "coop_rel", "earn", "earn_rel")

row_counter <- 1

for (participant_index in 1:nrow(dat)) {
  for (group_index in 1:16) {
    group_name_rel <- group_names_rel[group_index]
    data_for_participant <- dat[participant_index, ]
    
    dat_fair[row_counter, "participant"] <- data_for_participant$pp
    dat_fair[row_counter, "type"] <- data_for_participant$type
    
    dat_fair[row_counter, "svo_angle"] <- data_for_participant$svo_angle
    dat_fair[row_counter, "luck"] <- data_for_participant$luck
    dat_fair[row_counter, "merit"] <- data_for_participant$merit
    dat_fair[row_counter, "political_orientation"] <- data_for_participant$political_orientation
    dat_fair[row_counter, "economic_ideology"] <- data_for_participant$economic_ideology
    dat_fair[row_counter, "social_ideology"] <- data_for_participant$social_ideology
    
    dat_fair[row_counter, "pair"] <- substr(group_name_rel, 1, 4)
    dat_fair[row_counter, "type_in_pair"] <- substr(group_name_rel, 6, 7)
    
    coop_column <- paste0("fair_con_", group_name_rel)
    coop_rel_column <- paste0("fair_con_", group_name_rel, "_rel")
    dat_fair[row_counter, "coop"] <- data_for_participant[[coop_column]]
    dat_fair[row_counter, "coop_rel"] <- data_for_participant[[coop_rel_column]]
    
    #    earn_column <- paste0("fair_earn_", group_name_rel)
    earn_rel_column <- paste0("fair_earn_", group_name_rel, "_rel")
    #    values_fair[row_counter, "earn"] <- data_for_participant[[earn_column]]
    dat_fair[row_counter, "earn_rel"] <- data_for_participant[[earn_rel_column]]
    
    row_counter <- row_counter + 1
  }
}

dat_fair = as.data.frame(dat_fair)

dat_fair$type = ifelse(dat_fair$type == 1, "TP", dat_fair$type)
dat_fair$type = ifelse(dat_fair$type == 2, "HH", dat_fair$type)
dat_fair$type = ifelse(dat_fair$type == 3, "HL", dat_fair$type)
dat_fair$type = ifelse(dat_fair$type == 4, "LH", dat_fair$type)
dat_fair$type = ifelse(dat_fair$type == 5, "LL", dat_fair$type)

##########################################################################################

#save data frames
write.csv(dat, "dat_institutions.csv", row.names=FALSE)
write.csv(dat_long, "dat_long.csv", row.names=FALSE)
write.csv(dat_fair, "dat_fair.csv", row.names=FALSE)
