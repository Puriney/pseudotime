# Required pkgs
require(stringr)
require(useful)
if (suppressWarnings(require(xgboost))) {
} else {
  warning('xgboost not installed. Now installing xgboost')
  install.packages("drat", repos="https://cran.rstudio.com")
  drat:::addRepo("dmlc")
  install.packages("xgboost", repos="http://dmlc.ml/drat/", type = "source")
}
require(xgboost)
# if (suppressWarnings(require(mxnet))){
# } else {
#   warning('mxnet not installed. Now installing mxnet')
#   install.packages("drat", repos="https://cran.rstudio.com")
#   drat:::addRepo("dmlc")
#   install.packages("mxnet")
# }
# require(mxnet)
require(pROC)
# require(doMC)
require(dplyr)
# Env
wkdir <- getwd()
rawdir <- file.path(wkdir, 'raw')
figdir <- file.path(wkdir, 'fig')
if (!dir.exists(figdir)) dir.create(figdir)
modeldir <- file.path(wkdir, 'TrainedModel')
if (!dir.exists(modeldir)) dir.create(modeldir)
logdir <- file.path(wkdir, 'log')
if (!dir.exists(logdir)) dir.create(logdir)
datadir <- file.path(wkdir, 'data')
if(!dir.exists(datadir)) dir.create(datadir)
# Misc Helper Func
mytime <- function() {format(Sys.time(), "%y%m%d_%H%M_%s")}
mytimestamp <- function() {paste0(date(), '\n')}

# Env of pkg
theme_set(theme_bw(base_size = 26))
myGthm <- theme(text = element_text(size = 26))
