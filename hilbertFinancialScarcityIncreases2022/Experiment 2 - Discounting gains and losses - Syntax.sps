* Encoding: UTF-8.
**** Labels and Variable types. 

DATASET ACTIVATE DataSet1.

Alter type Age (F2).
Variable level Age (SCALE).
Execute. 

Compute Balance = REPLACE (Balance, '.', ','). 
Execute. 

Alter type Balance CondNum (F40.2).
Variable level Balance CondNum (SCALE). 

VALUE LABELS CondNum
1 'Abundance'
2 'Scarcity'. 
EXECUTE.

If sysmis(TDneg410) Discount = 1. 
If sysmis(TD410) Discount = 2. 
Execute. 

VALUE LABELS Discount
1 'Gains'
2 'Losses'. 
EXECUTE.

RENAME VARIABLES Q178 = TD_neg_exact.
Execute. 

COMPUTE TD_exact_tot = MAX(TD_exact, TD_neg_exact).
Execute. 

Variable level TD_exact_tot (SCALE).
Execute. 


*** Exclusion of participants. 

Compute Exclude = 0. 
Execute. 

*** Exclude participants who switch multiple times --> multiple indiffernce points.
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

Compute SwitchCount =0. 
IF TDneg410 NE TDneg390 SwitchCount = SwitchCount + 1.
IF TDneg390 NE TDneg370 SwitchCount = SwitchCount + 1.
IF TDneg370 NE TDneg350 SwitchCount = SwitchCount + 1.
IF TDneg350 NE TDneg330 SwitchCount = SwitchCount + 1.
IF TDneg330 NE TDneg310 SwitchCount = SwitchCount + 1.
IF TDneg310 NE TDneg290 SwitchCount = SwitchCount + 1.
IF TDneg290 NE TDneg270 SwitchCount = SwitchCount + 1.
IF TDneg270 NE TDneg250 SwitchCount = SwitchCount + 1.
IF TDneg250 NE TDneg230 SwitchCount = SwitchCount + 1.
Execute.  

FREQUENCIES VARIABLES=SwitchCount
  /ORDER=ANALYSIS.


If SwitchCount GT 1 Exclude = 1.
Execute.


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

IF TDneg410 EQ 2 AND SwitchCount EQ 0 IndiffPoint = 420.
IF TDneg410 EQ 1 AND TDneg390 EQ 2 IndiffPoint = 400. 
IF TDneg390 EQ 1 AND TDneg370 EQ 2 IndiffPoint = 380. 
IF TDneg370 EQ 1 AND TDneg350 EQ 2 IndiffPoint = 360. 
IF TDneg350 EQ 1 AND TDneg330 EQ 2 IndiffPoint = 340. 
IF TDneg330 EQ 1 AND TDneg310 EQ 2 IndiffPoint = 320. 
IF TDneg310 EQ 1 AND TDneg290 EQ 2 IndiffPoint = 300. 
IF TDneg290 EQ 1 AND TDneg270 EQ 2 IndiffPoint = 280. 
IF TDneg270 EQ 1 AND TDneg250 EQ 2 IndiffPoint = 260. 
IF TDneg250 EQ 1 AND TDneg230 EQ 2 IndiffPoint = 240. 
IF TDneg230 EQ 1 AND SwitchCount EQ 0 IndiffPoint = 220.
Execute.  

** Participants no. 115 and 130 do not have a indifference point because they switch in a way that is only posssible if you have a preference for losses and are thus excluded. 

If TD410 EQ 1 AND SwitchCount NE 0 Exclude =1.
If TDneg410 EQ 2 AND SwitchCount NE 0 Exclude = 1. 

USE ALL.
COMPUTE filter_$=(Exclude   ~=   1).
VARIABLE LABELS filter_$ 'Exclude   ~=   1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

**** Descriptives.


FREQUENCIES VARIABLES=IndiffPoint
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Gender
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Age
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.

* One participant entered 339 years. Given that the rest of his response patterns were unsuspicious, we decided to assume that this is a typo and the participant wanted to type 39 years instead. 

If Age EQ 339 Age = 39. 


*** Hypothesis test.

UNIANOVA IndiffPoint BY Discount CondNum
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(CondNum*Discount) TYPE=BAR ERRORBAR=CI MEANREFERENCE=No
  /EMMEANS=TABLES(Discount) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(CondNum) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(CondNum*Discount) COMPARE(CondNum) ADJ(LSD)
  /EMMEANS=TABLES(CondNum*Discount) COMPARE(Discount) ADJ(LSD)
  /PRINT F ETASQ DESCRIPTIVE HOMOGENEITY OPOWER
  /CRITERIA=ALPHA(.05)
  /DESIGN=Discount CondNum CondNum*Discount.



