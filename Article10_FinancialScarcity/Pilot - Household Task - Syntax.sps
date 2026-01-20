* Encoding: UTF-8.
 Encoding: UTF-8.

DATASET ACTIVATE DataSet1.

***************************************
*** Recode and compute variables. 
*Recode. 
Alter type Age (F2).
Variable level Age (SCALE).
Execute. 

IF Condition EQ 'High income' CondNum = 1. 
IF Condition EQ 'Medium income' CondNum = 2. 
IF Condition EQ 'Low income' CondNum = 3. 
Execute. 

Value Labels
CondNum
1 High income
2 Medium income
3 Low income.
Execute. 


RECODE DV01_2 DV01_5 DV01_6 DV01_8 DV01_10 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into DV01_2r DV01_5r DV01_6r DV01_8r DV01_10r.
Execute. 

Variable Level DV01_2r DV01_5r DV01_6r DV01_8r DV01_10r (SCALE).
Execute.

**Compute Variables. 

Compute PIFS = (PIFS_1 + PIFS_2 + PIFS_3 + PIFS_4 + PIFS_5 + PIFS_6 + PIFS_7 + PIFS_8 + PIFS_9 +PIFS_10 + PIFS_11 +PIFS_12)/12. 
Execute.

Compute Scarcity = (DV01_1 + DV01_2r + DV01_3 + DV01_4 + DV01_5r + DV01_6r + DV01_7 + DV01_8r + DV01_9 + DV01_10r + DV01_11)/11.
Execute.

**Compute mean centered variables. 

*Create new variable holding mean over original variable.

aggregate outfile * mode addvariables
/mean_PIFS = mean(PIFS)
/mean_income = mean(Income).

*Subtract mean from original values.

compute cent_PIFS = PIFS - mean_PIFS.
compute cent_income = Income - mean_income.

*Add variable label to centered variable.

variable labels cent_PIFS "Psychological Inventory of Financial Scarcity (centered)".
variable labels cent_income "Income (centered)".

*Check results.

descriptives PIFS cent_PIFS Income cent_income.

*Delete helper variable.

delete variables mean_PIFS mean_Income.




*********** 
***Descriptives.

 FREQUENCIES VARIABLES=CondNum
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Income Age PIFS
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN MODE SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Gender
  /ORDER=ANALYSIS.


FREQUENCIES VARIABLES=PIFS Scarcity
  /FORMAT=NOTABLE
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.



*** Reliability. 
*Scarcity.
RELIABILITY
  /VARIABLES=DV01_2r DV01_5r DV01_6r DV01_8r DV01_10r DV01_1 DV01_3 DV01_4 DV01_7 DV01_9 DV01_11
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR ANOVA
  /SUMMARY=TOTAL.

*PIFS.
RELIABILITY
  /VARIABLES=PIFS_1 PIFS_2 PIFS_3 PIFS_4 PIFS_5 PIFS_6 PIFS_7 PIFS_8 PIFS_9 PIFS_10 PIFS_11 PIFS_12
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR ANOVA
  /SUMMARY=TOTAL.



**** Main analysis.
UNIANOVA Scarcity BY CondNum
  /CONTRAST(CondNum)=Simple(2)
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PRINT ETASQ TEST(LMATRIX) DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum.

ONEWAY Scarcity BY CondNum
  /CONTRAST=1 -1 0 
  /CONTRAST=0 1 -1 
  /MISSING ANALYSIS.


***Testing for covariates. 

UNIANOVA Scarcity BY CondNum WITH cent_PIFS
  /CONTRAST(CondNum)=Simple
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(CondNum) WITH(cent_PIFS=MEAN) 
  /PRINT ETASQ TEST(LMATRIX) DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum cent_PIFS CondNum*cent_PIFS.

UNIANOVA Scarcity BY CondNum WITH cent_income
  /CONTRAST(CondNum)=Simple
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(CondNum) WITH(cent_income=MEAN) 
  /PRINT F ETASQ DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum cent_income CondNum*cent_income.



