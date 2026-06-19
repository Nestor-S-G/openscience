* Encoding: UTF-8. /* (Automatically added by SPSS when saving the file; cannot be deleted.) */

/* CONFIGURATION: */

/* File system paths: */

* TODO: Change <project_path> to local, e.g.:
* FILE HANDLE project_dir /NAME = 'C:/Users/Daniel Morillo/Documents/Workspace/openscience'.
FILE HANDLE project_dir /NAME = '.'.

FILE HANDLE scarcity_dir /NAME = 'project_dir/hilbertFinancialScarcityIncreases2022'.


/* PILOT STUDY: */

/* File paths: */
FILE HANDLE pilot_data   /NAME = 'scarcity_dir/Pilot - Household Task - Raw Data.sav'.
FILE HANDLE pilot_syntax /NAME = 'scarcity_dir/Pilot - Household Task - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'pilot_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'pilot_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Pilot.xlsx'.

/* Experiment 1: */

/* File paths: */
FILE HANDLE e1_data   /NAME = 'scarcity_dir/Experiment 1 - Discounting gains - Raw Data.sav'.
FILE HANDLE e1_syntax /NAME = 'scarcity_dir/Experiment 1 - Discounting gains - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'e1_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'e1_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp1.xlsx'.

/* Experiment 2: */

/* File paths: */
FILE HANDLE e2_data   /NAME = 'scarcity_dir/Experiment 2 - Discounting gains and losses - Raw Data.sav'.
FILE HANDLE e2_syntax /NAME = 'scarcity_dir/Experiment 2 - Discounting gains and losses - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'e2_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'e2_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp2.xlsx'.

/* Experiment 3: */

/* File paths: */
FILE HANDLE e3_data   /NAME = 'scarcity_dir/Experiment 3 - Scarcity mindset and late shock - Raw data.sav'.
FILE HANDLE e3_syntax /NAME = 'scarcity_dir/Experiment 3 - Scarcity mindset and late shock - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'e3_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'e3_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp3.xlsx'.


/* Experiment 4: */

/* File paths: */
FILE HANDLE e4_data   /NAME = 'scarcity_dir/Experiment 4 - Scarcity mindset and early shock - Raw data.sav'.
FILE HANDLE e4_syntax /NAME = 'scarcity_dir/Experiment 4 - Scarcity mindset and early shock - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'e4_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'e4_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp4.xlsx'.


/* Experiment 5: */

/* File paths: */
FILE HANDLE e5_data   /NAME = 'scarcity_dir/Experiment 5 - Scarcity mindset and endowment - Raw data.sav'.
FILE HANDLE e5_syntax /NAME = 'scarcity_dir/Experiment 5 - Scarcity mindset and endowment - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'e5_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'e5_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\Exp5.xlsx'.


/* Additional Study: */

/* File paths: */
FILE HANDLE as_data   /NAME = 'scarcity_dir/Additional Study - Temporal discounting and a mindset manipulation - Raw data.sav'.
FILE HANDLE as_syntax /NAME = 'scarcity_dir/Additional Study - Temporal discounting and a mindset manipulation - Syntax.sps'.


/* Main: */

* Read data set.
GET FILE = 'as_data'.
DATASET NAME DataSet1. /* Dataset name used in the syntax file. */

* Run syntax.
INSERT FILE = 'as_syntax'.

* Export results.
OUTPUT EXPORT /XLSX DOCUMENTFILE='scarcity_dir\AdS.xlsx'.