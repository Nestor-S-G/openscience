* Encoding: UTF-8. /* (Automatically added by SPSS when saving the file; cannot be deleted.) */

/* CONFIGURATION: */

/* File system paths: */

* TODO: Change <project_path> to local, e.g.:
* FILE HANDLE project_dir /NAME = 'C:/Users/Daniel Morillo/Documents/Workspace/openscience'.
FILE HANDLE project_dir /NAME = '<project_path>'.

FILE HANDLE scarcity_dir /NAME = 'project_dir/Article10_FinancialScarcity'.


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