# Instructions to replicate results

In order to replicate the results of the paper, run each script in order of their
numbering to set up the data, preprocess and generateresults and figures as shown in
the journal article.

You will need to set the `data_path` variable to your local folder with the data
files in the first script (`01_combine_participant_data.ipynb`). The resulting file
from this script will then need to be added as the input for the second script:
`02_load_data_to_R.R`
