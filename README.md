# <img src=http://i.imgur.com/padql1E.png width=70/> pseudotimer

---

**Where is the data**

Put the raw data into *raw* folder first.

**Where are the functional code**

In *src* folder, there are following R scripts:

- `setup.R`: install required R packages
- `dependencies.R`: set up working environment
- `io.R`: read-in input data and prepare training and testing dataset
- `model_xgboost.R`: use xgboost for modeling and prediction
- `model_NN.R`: to-do

**How to run**
There are two alternatives:

- In terminal concole, run `Rscript run.R -w <working_directory> -s <starting_stage>`. Run `Rscript run.R --help` for details.
- In R concole, `source` whatever R files under *src* folder.
