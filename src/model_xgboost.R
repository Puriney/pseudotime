##
## xgboost
##
logfile <- file.path(logdir, paste0('xgboost_', mytime(), '.log'))
sink(logfile)
message("##------ xgboost ------##")
cat('START\n')

## training parameters
num_classes <- length(hr_int)
xbt_param0 <- list("objective" = "multi:softprob",
                    "eval_metric" = "mlogloss",
                    "num_class" = num_classes)
## hardwares
num_threads <- 3

## Tuning
cat("Grid Parameters Tuning", "at", mytimestamp())

## tunning grid
xbt_param_grid <- expand.grid(subsample = c(0.5, 0.75, 1),
                              eta = c(0.1),
                              max_depth = c(16, 32, 64))

names_param_tune <- colnames(xbt_param_grid)
num_param_set <- dim(xbt_param_grid)[1]
cv_nround <- 1000
num_bstrees <- 0 ## to-be tuned
cv_fold   <- 10
rounds_after_x <- 5
res_tuning <- sapply(1:num_param_set, function(i){
  tune_params <- xbt_param_grid[i, ]
  tuning <- as.list(as.numeric(tune_params))
  names(tuning) <- names_param_tune

  xbt_param <- c(xbt_param0, tuning)
  cat("Tuning Param Set", i, "/", num_param_set, "at", mytimestamp())
  set.seed(1026)
  bst_cv <- xgb.cv(params = xbt_param,
                   data = tr_x,
                   label = tr_yInt - 1,
                   nfold = cv_fold,
                   nrounds =  cv_nround,
                   nthread = num_threads,
                   print.every.n = ceiling(cv_nround / 10),
                   prediction = TRUE,
                   maximize = FALSE,
                   early.stop.round = rounds_after_x)
  cv_run_rounds <- dim(bst_cv$dt)[1]
  num_bstrees <- ifelse(cv_run_rounds < cv_nround,
                        cv_run_rounds - rounds_after_x, cv_nround)
  cat('Finish Param Set', i, "/", num_param_set, "at", mytimestamp())
  cat('num_trees:', num_bstrees, '\n')
  report <- c(tuning, list(mlogloss = bst_cv$dt$test.mlogloss.mean[num_bstrees],
                                nrounds = num_bstrees))
  cat('mlogloss:', bst_cv$dt$test.mlogloss.mean[num_bstrees], '\n')
  rm(bst_cv)
  return(unlist(report))
}, simplify = TRUE)

## Selecting 'Best' Parameter
res_tuning <- data.frame(t(res_tuning), stringsAsFactors = FALSE)
print(res_tuning)
save(res_tuning,
     file=file.path(logdir, paste0('XGBoost_tuning_', mytime() ,'.RData')))
res_tuning <- arrange(res_tuning, mlogloss,
                      desc(nrounds), desc(subsample), eta, max_depth)

i <- which.min(res_tuning[, 'mlogloss'])
if (i != 1) warning("Should Recheck Sorting...")
cat('Best parameters set is :\n')
xbt_param_tuned <- res_tuning[i, names_param_tune]
num_bstrees <- as.numeric(res_tuning[i, 'nrounds'])
xbt_param_tuned <- as.list(as.numeric(xbt_param_tuned))
names(xbt_param_tuned) <- c(names_param_tune)
cat('num_rounds:', num_bstrees, '\n')
print(xbt_param_tuned)

## Training
cat("Training xgboost at", mytimestamp())
xbt_param <- c(xbt_param0, xbt_param_tuned)
bst_trained <- FALSE
bst <- xgboost(params = xbt_param,
               data   = tr_x,
               label  = tr_yInt - 1, ## meet xgboost input format
               nrounds = num_bstrees,
               print.every.n = ceiling(num_bstrees / 10),
               nthread = num_threads
)
bst_trained <- TRUE

## Save model
if (bst_trained){
  cat("Finish xgboost and saving\n")
  xgb.save(bst, file.path(modeldir, paste0("XGBoost", mytime(), ".xgb")))
  cat('End at', mytimestamp())
  bst_trained <- FALSE
} else {
  warning("xgboost tree is not trained yet\n")
}

## Prediction

te_PredProb0 <- predict(bst, te_x)

## Evaluation: Log Loss function
eps = 1e-15
te_PredProb <- pmin(pmax(te_PredProb0, eps), 1-eps)
te_PredProbM <- matrix(te_PredProb, ncol = num_classes, byrow = TRUE) # N x Class

#' Multiple-Label Log Loss function
#' \param{p} Probability matrix. N x Classes.
#' \param{y} Labels. 1-based index.
MultiLogLoss <- function(p, y){
  m <- dim(p)[2]
  n <- dim(p)[1]
  p <- log(p)
  res <- -1 * sum(sapply(seq_len(n), function(i) {
                          j <- y[i]
                          as.numeric(p[i, j])
                  })) / n
  res
}
cat("Report: LogLoss on unseen test dataset of xgboost is ")
cat(MultiLogLoss(te_PredProbM, te_yInt), '\n')
cat('END\n')
sink()

te_PredTime <- apply(te_PredProbM, 1, function(x) crossprod(x, 1:num_classes))
