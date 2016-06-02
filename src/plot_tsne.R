df_uniq <- unique(df)

df_uniq_tsne_obj <- Rtsne(df_uniq)
if (file.exists(file.path(logdir, 'full_data_tsne_obj.RData'))) {
  load(file = file.path(logdir, 'full_data_tsne_obj.RData'))
} else{
  save(df_uniq_tsne_obj, file = "log/full_df_tsne.RData")
}

df_tsne_dt <- as.data.frame(df_uniq_tsne_obj$Y)
colnames(df_tsne_dt) <- c('tSNE_1', 'tSNE_2')

cat("Plotting tSNE\n")

p <- ggplot(df_tsne_dt, aes(tSNE_1, tSNE_2)) +
  geom_point(aes(color = factor(corgs[, 'hr_factor'])), size = 3, alpha = .7) +
  labs(color = 'Labels') +
  ggtitle(paste0('Full dataset (', dim(df_tsne_dt)[1], ' cells)')) +
  scale_colour_brewer(palette = "Set1") +
  coord_fixed(ratio = 1)
tmpfig <- file.path(figdir, 'full_df_tsne.pdf')
pdf(file = tmpfig, width = 7, height = 7)
print(p)
dev.off()

cat("Plot tSNE on test dataset with labels masked")
te_id <- which(cnames %in% te_cnames)
te_tsne_dt <- df_tsne_dt[te_id, ]
p <- ggplot(te_tsne_dt, aes(tSNE_1, tSNE_2)) +
  geom_point(aes(color = factor(corgs[te_cnames, 'hr_factor'])), size = 3) +
  labs(color = 'Labels') +
  ggtitle(paste0('Test dataset (', length(te_cnames), ' cells)')) +
  scale_colour_brewer(palette = "Spectral", direction = 1) +
  coord_fixed(ratio = 1)
tmpfig <- file.path(figdir, 'testdataset_tsne.pdf')
pdf(file = tmpfig, width = 7, height = 7)
print(p)
dev.off()

cat("Plot tSNE on test dataset with predicted time")
te_tsne_dt_pred <- cbind(te_tsne_dt, Time = te_PredTime * 6)
p <- ggplot(te_tsne_dt_pred, aes(tSNE_1, tSNE_2)) +
  geom_point(aes(colour = Time), size = 3) +
  ggtitle(paste0('Test dataset Prediction (', length(te_cnames), ' cells)')) +
  scale_colour_distiller(palette = 'Spectral', direction = 1) +
  coord_fixed(ratio = 1)
tmpfig <- file.path(figdir, 'testdataset_tsne_TimeProb.pdf')
pdf(file = tmpfig, width = 7, height = 7)
print(p)
dev.off()

