* Encoding: UTF-8.
 Encoding: UTF-8.
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
*5 participants. 

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

T-TEST GROUPS=ShockVar(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=IndiffPoint
  /ES DISPLAY(TRUE)
  /CRITERIA=CI(.95).

MEANS TABLES=IndiffPoint BY ShockVar
  /CELLS=MEAN COUNT STDDEV.



DATASET ACTIVATE DataSet1.
SORT CASES  BY ShockVar.
SPLIT FILE SEPARATE BY ShockVar.

FREQUENCIES VARIABLES=IndiffPoint
  /ORDER=ANALYSIS.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=IndiffPoint MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: IndiffPoint=col(source(s), name("IndiffPoint"))
  GUIDE: axis(dim(1), label("IndiffPoint"))
  GUIDE: axis(dim(2), label("Frequency"))
  GUIDE: text.title(label("Simple Bar of IndiffPoint"))
  ELEMENT: interval(position(summary.count(bin.rect(IndiffPoint))), shape.interior(shape.square))
END GPL.


SPLIT FILE OFF.
