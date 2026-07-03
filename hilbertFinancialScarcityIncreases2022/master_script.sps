* Encoding: UTF-8.

/* CONFIGURATION: */

FILE HANDLE project_dir /NAME = 'C:/Users/Daniel Morillo/Documents/Workspace/openscience'.
FILE HANDLE scarcity_dir /NAME = 'project_dir/hilbertFinancialScarcityIncreases2022'.


/* PILOT STUDY: */
FILE HANDLE pilot_data   /NAME = 'scarcity_dir/Pilot - Household Task - Raw Data.sav'.
FILE HANDLE pilot_syntax /NAME = 'scarcity_dir/Pilot - Household Task - Syntax.sps'.

GET FILE = 'pilot_data'.
DATASET NAME DataSet1.
INSERT FILE = 'pilot_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Pilot.xlsx'.
OUTPUT CLOSE *.


/* Experiment 1: */
DATASET CLOSE ALL.

FILE HANDLE e1_data   /NAME = 'scarcity_dir/Experiment 1 - Discounting gains - Raw Data.sav'.
FILE HANDLE e1_syntax /NAME = 'scarcity_dir/Experiment 1 - Discounting gains - Syntax.sps'.

GET FILE = 'e1_data'.
DATASET NAME DataSet1.
INSERT FILE = 'e1_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp1.xlsx'.
OUTPUT CLOSE *.


/* Experiment 2: */
DATASET CLOSE ALL.

FILE HANDLE e2_data   /NAME = 'scarcity_dir/Experiment 2 - Discounting gains and losses - Raw Data.sav'.
FILE HANDLE e2_syntax /NAME = 'scarcity_dir/Experiment 2 - Discounting gains and losses - Syntax.sps'.

GET FILE = 'e2_data'.
DATASET NAME DataSet1.
INSERT FILE = 'e2_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp2.xlsx'.
OUTPUT CLOSE *.


/* Experiment 3: */
DATASET CLOSE ALL.

FILE HANDLE e3_data   /NAME = 'scarcity_dir/Experiment 3 - Scarcity mindset and late shock - Raw data.sav'.
FILE HANDLE e3_syntax /NAME = 'scarcity_dir/Experiment 3 - Scarcity mindset and late shock - Syntax.sps'.

GET FILE = 'e3_data'.
DATASET NAME DataSet1.
INSERT FILE = 'e3_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp3.xlsx'.
OUTPUT CLOSE *.


/* Experiment 4: */
DATASET CLOSE ALL.

FILE HANDLE e4_data   /NAME = 'scarcity_dir/Experiment 4 - Scarcity mindset and early shock - Raw data.sav'.
FILE HANDLE e4_syntax /NAME = 'scarcity_dir/Experiment 4 - Scarcity mindset and early shock - Syntax.sps'.

GET FILE = 'e4_data'.
DATASET NAME DataSet1.
INSERT FILE = 'e4_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp4.xlsx'.
OUTPUT CLOSE *.


/* Experiment 5: */
DATASET CLOSE ALL.

FILE HANDLE e5_data   /NAME = 'scarcity_dir/Experiment 5 - Scarcity mindset and endowment - Raw data.sav'.
FILE HANDLE e5_syntax /NAME = 'scarcity_dir/Experiment 5 - Scarcity mindset and endowment - Syntax.sps'.

GET FILE = 'e5_data'.
DATASET NAME DataSet1.
INSERT FILE = 'e5_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp5.xlsx'.
OUTPUT CLOSE *.


/* Additional Study: */
DATASET CLOSE ALL.

FILE HANDLE as_data   /NAME = 'scarcity_dir/Additional Study - Temporal discounting and a mindset manipulation - Raw data.sav'.
FILE HANDLE as_syntax /NAME = 'scarcity_dir/Additional Study - Temporal discounting and a mindset manipulation - Syntax.sps'.

GET FILE = 'as_data'.
DATASET NAME DataSet1.
INSERT FILE = 'as_syntax'.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\AdS.xlsx'.
OUTPUT CLOSE *.
