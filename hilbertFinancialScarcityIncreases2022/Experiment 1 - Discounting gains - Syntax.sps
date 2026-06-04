* Encoding: UTF-8.
*** Data preparation. 

Alter type Age (F2).
Variable level Age (SCALE).
Execute. 

Compute Balance = REPLACE (Balance, '.', ','). 
Execute. 

Alter type Balance (F40.2).
Variable level Balance (SCALE). 

Missing values Income (13).
Execute. 

*IV.
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


*** Exclusion of participants. 

Compute Exclude = 0. 
Execute. 

** Exclude participants who switch multiple times --> multiple indiffernce points.
Compute SwitchCount =0. 
IF TD410 NE TD390 SwitchCount = SwitchCount + 1.
IF TD390 NE TD370 SwitchCount = SwitchCount + 1.
IF TD370 NE TD350 SwitchCount = SwitchCount + 1.
IF TD350 NE TD330 SwitchCount = SwitchCount + 1.
IF TD330 NE TD310 SwitchCount = SwitchCount + 1.
IF TD310 NE TD290 SwitchCount = SwitchCount + 1.
IF TD290 NE TD270 SwitchCount = SwitchCount + 1.
IF TD270 NE TD250 SwitchCount = SwitchCount + 1.
IF TD250 NE TD230 SwitchCount = SwitchCount + 1.
Execute.  

FREQUENCIES VARIABLES=SwitchCount
  /ORDER=ANALYSIS.

If SwitchCount GT 1 Exclude = 1.
Execute.
*4 participants. 

** Preference for less rewards. 
If TD410 EQ 1 AND SwitchCount NE 0 Exclude =1.

FREQUENCIES VARIABLES=Exclude
  /ORDER=ANALYSIS.
*0 participants. 

USE ALL.
COMPUTE filter_$=(Exclude   ~=   1).
VARIABLE LABELS filter_$ 'Exclude   ~=   1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


*** Compute Indifference point. 

IF TD410 EQ 1 AND SwitchCount EQ 0 IndiffPoint = 420.
IF TD410 EQ 2 AND TD390 EQ 1 IndiffPoint = 400. 
IF TD390 EQ 2 AND TD370 EQ 1 IndiffPoint = 380. 
IF TD370 EQ 2 AND TD350 EQ 1 IndiffPoint = 360. 
IF TD350 EQ 2 AND TD330 EQ 1 IndiffPoint = 340. 
IF TD330 EQ 2 AND TD310 EQ 1 IndiffPoint = 320. 
IF TD310 EQ 2 AND TD290 EQ 1 IndiffPoint = 300. 
IF TD290 EQ 2 AND TD270 EQ 1 IndiffPoint = 280. 
IF TD270 EQ 2 AND TD250 EQ 1 IndiffPoint = 260. 
IF TD250 EQ 2 AND TD230 EQ 1 IndiffPoint = 240. 
IF TD230 EQ 2 AND SwitchCount EQ 0 IndiffPoint = 220.
Execute.  


*** Sample.

FREQUENCIES VARIABLES=Age Income
  /FORMAT=NOTABLE
  /STATISTICS=STDDEV MEAN MEDIAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Gender
  /ORDER=ANALYSIS.


*** Descriptives. 

FREQUENCIES VARIABLES=IndiffPoint
  /ORDER=ANALYSIS.


*** Main analysis. 

UNIANOVA IndiffPoint BY CondNum
  /CONTRAST(CondNum)=Simple
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PRINT F ETASQ DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum.

ONEWAY IndiffPoint BY CondNum
  /CONTRAST=1 -1 0 
  /CONTRAST=0 1 -1 
  /CONTRAST=1 0 -1
  /MISSING ANALYSIS.


*** Alternative analysis. 
** With the direct measure of the indifference point.

FREQUENCIES VARIABLES=TD_exact
  /STATISTICS=STDDEV MEAN SKEWNESS SESKEW
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

*Highly skewed. Thus analysis with log. 

COMPUTE TD_exact_ln=LN(TD_exact).
EXECUTE.

FREQUENCIES VARIABLES=TD_exact_ln
  /STATISTICS=STDDEV MEAN SKEWNESS SESKEW
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.
 
UNIANOVA TD_exact_ln BY CondNum
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(OVERALL) 
  /PRINT F ETASQ DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum.

** To show that the results with the linear transformation are exactly the same as the reported one.
* Calculate discount factor (k) using the hyperbolic discounting formular k=(A/V-1)/time in years, with A = future gain and V = immediate gain.  

COMPUTE disc_rate_k=(IndiffPoint/250-1)/1.
EXECUTE.

FREQUENCIES VARIABLES=disc_rate_k
  /STATISTICS=STDDEV MEAN SKEWNESS SESKEW
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

UNIANOVA disc_rate_k BY CondNum
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PRINT F ETASQ DESCRIPTIVE PARAMETER HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=CondNum.
