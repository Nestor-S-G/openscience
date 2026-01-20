* Encoding: UTF-8.

*** Exclude participants with low consistency scores. 

FREQUENCIES VARIABLES=consistent_choice
  /ORDER=ANALYSIS.


DATASET ACTIVATE DataSet1.
USE ALL.
COMPUTE filter_$=(consistent_choice  >=  0.75).
VARIABLE LABELS filter_$ 'consistent_choice  >=  0.75 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


*** Compute PIFS and subscales. 

compute PIFS = mean(Q30_1, Q30_2, Q30_3, Q30_4, Q30_5, Q30_6, Q30_7, Q30_8, Q30_9, Q30_10, Q30_11, Q30_12).
compute little_money = mean(Q30_1, Q30_2, Q30_3).
compute worry = mean(Q30_4, Q30_5, Q30_6).
compute short_term = mean(Q30_7, Q30_8, Q30_9).
compute control = mean(Q30_10, Q30_11, Q30_12).


***Descriptives.

**PIFS.
  FREQUENCIES VARIABLES=PIFS little_money worry short_term control
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

reliability
  /variables= Q30_1 Q30_2 Q30_3
Q30_4 Q30_5 Q30_6
Q30_7 Q30_8 Q30_9
Q30_10 Q30_11 Q30_12
  /scale('PIFS') all
  /model=alpha
  /summary=total. 


**Discount rates.
DESCRIPTIVES VARIABLES=overall_k
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

GRAPH
  /HISTOGRAM=overall_k.

*Discount rates are skewed, use natural logarithm. 
COMPUTE ln_over_k=LN(overall_k).
EXECUTE.

GRAPH
  /HISTOGRAM=ln_over_k.



*** Main analyses. 

CORRELATIONS
  /VARIABLES=ln_over_k PIFS little_money worry short_term control
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.



