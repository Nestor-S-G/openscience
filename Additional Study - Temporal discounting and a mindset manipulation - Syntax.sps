* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.


*** Variable preparartion. 


Alter type Age (F2).
Variable level Age (SCALE).
Execute. 

Alter type Balance CondNum (F40.2).
Variable level Balance CondNum (ORDINAL). 

VALUE LABELS CondNum
1 'Abundance'
2 'Scarcity'. 
EXECUTE.

*** Filter finished study. --> All participants with progress = 100 and participant no. 176 with progress = 98. 


If Progress GE 98 Exclude = 0.
If Progress LT 98 Exclude = 1. 
Execute. 


FREQUENCIES VARIABLES=Exclude
  /ORDER=ANALYSIS.

USE ALL.
COMPUTE filter_$=(Exclude    ~= 1).
VARIABLE LABELS filter_$ 'Exclude    ~= 1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

***Exclude participants with consistency score lower than 75%. 

FREQUENCIES VARIABLES=Overall_Consistency
  /ORDER=ANALYSIS.

If Overall_Consistency LT 0.75 Exclude = 1. 
Execute. 

FREQUENCIES VARIABLES=Exclude
  /ORDER=ANALYSIS.

* 1 participant excluded. 

USE ALL.
COMPUTE filter_$=(Exclude    ~= 1).
VARIABLE LABELS filter_$ 'Exclude    ~= 1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.



  **** Data exploration.
    
    FREQUENCIES VARIABLES=Overall_k ln_Overall_k
      /FORMAT=NOTABLE
      /STATISTICS=STDDEV MINIMUM MAXIMUM SEMEAN MEAN MEDIAN SKEWNESS SESKEW KURTOSIS SEKURT
      /HISTOGRAM NORMAL
      /ORDER=ANALYSIS.
    
    
* Skewed discount rates. 


**** Descriptives.

FREQUENCIES VARIABLES=Gender CondNum
  /ORDER=ANALYSIS.


FREQUENCIES VARIABLES=Age
  /FORMAT=NOTABLE
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.

*** Main hypothesis test.  

T-TEST GROUPS=CondNum(1 2)
  /MISSING=ANALYSIS
  /VARIABLES=ln_Overall_k
  /CRITERIA=CI(.95).





