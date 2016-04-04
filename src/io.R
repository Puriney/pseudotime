# Read-in data
# fpath <- "~/Yun_Codes/Projects/pseudotime/raw/esc_no_batch.logTPM.txt"
datapath <- file.path(datadir, 'input.RData')
if (file.exists(datapath)) {
  load(datapath)
}

fpath <- file.path(rawdir, 'esc_no_batch.logTPM.txt')
raw <- read.delim(fpath, row.names=1, comment.char="#", stringsAsFactors=FALSE)

# Checkings
gnames <- rownames(raw)
cat("Whether row names (gene names) are NOT duplicated?")
cat(length(gnames) == length(unique(gnames)))

cat("How cells/experiments are organized?")
cat("Column names samples:")
cnames <- colnames(raw)
print(cnames[sample(1:length(cnames), 10, F)])

name_pattern <- "(esc[0-9]+)_([0-9]+)h_([0-9]+)_rsem"
corgs <- str_match(cnames, name_pattern)
corgs <- as.data.frame(corgs, stringsAsFactors = F)
colnames(corgs) <- c('cname', 'batch_name', 'hour', 'ci')

cat("Unique batch name(s):")
print(unique(corgs[, 'batch_name']))
cat("Unique hour(s):")
print(unique(corgs[, 'hour']))

# Prepare labels for each cell
corgs$hour <- as.numeric(corgs$hour)
corgs$ci   <- as.numeric(corgs$ci)
rownames(corgs) <- corgs$cname

hr_int <- sort(unique(corgs$hour))
hr_factor <- factor(corgs$hour, levels = hr_int,
                    labels = paste0('h', hr_int))
corgs$hr_factor <- hr_factor

# Check label (im)balance
tmpfig <- file.path(figdir, 'label_balance.pdf')
if (!file.exists(tmpfig)) {
  tmp <- as.data.frame(table(corgs$hr_factor))
  p <- ggplot(tmp, aes(Var1, Freq)) +
    geom_bar(stat = 'identity', fill = 'steelblue') +
    xlab("Time Point (hr)") + ylab("Count") +
    ggtitle(paste0("Experiment: ",
                   unique(corgs$batch_name), ' (', length(corgs$cname), ')')) +
    geom_text(aes(label = Freq), size = 7, vjust = -0.1)
  pdf(file = tmpfig, width = 8, height = 8)
  print(p)
  dev.off()
}

# Prepare Train and Test dataset
df <- t(raw)
if (!file.exists(datapath)) save(df, file = datapath)

train_ratio <- 0.8
set.seed(20160329)
tr_cnames <- sort(sample(cnames, ceiling(length(cnames) * train_ratio), replace = F))
te_cnames <- sort(setdiff(cnames, tr_cnames))

tr_x <- df[tr_cnames, ]
tr_y <- corgs[tr_cnames, 'hr_factor']
tr_yInt <- as.numeric(tr_y)  # 1=0h, 2=6h, ...

te_x <- df[te_cnames, ]
te_y <- corgs[te_cnames, 'hr_factor']
te_yInt <- as.numeric(te_y)

# Shrink train dataset features to test pipeline
# tmp <- sort(sample(1:length(gnames), 100, F))
# tr_x <- tr_x[, tmp]
# te_x <- te_x[, tmp]
