#!/user/bin/env Rscript
if (suppressWarnings(require(optparse))){
} else {
  install.packages('optparse')
}
require(optparse)
opt_list <- list(
  make_option(c("-w", "--workdir"), type = "character", default = getwd(),
              help = "Absolute path to set working director",
              metavar = "character"),
  make_option(c("-s", "--stage"), type = "integer", default = 0,
              help = "Set stage to begin pipeline.
              0: setup;
              10: dependencies;
              20: io;
              30: model training model_xgboost", metavar = "integer")
)

opt_parser <- OptionParser(option_list = opt_list)
opt <- parse_args(opt_parser)

wkdir <- opt$workdir
if (!dir.exists(wkdir)) dir.create(wkdir)
setwd(wkdir)

if (opt$stage <= 0)  source('src/setup.R')
if (opt$stage <= 10) source('src/dependencies.R')
if (opt$stage <= 20) source('src/io.R')
if (opt$stage <= 30) source(file.path(wkdir, 'src', 'model_xgboost.R'))
if (opt$stage > 30)  stop("Unknown starting stage!")

