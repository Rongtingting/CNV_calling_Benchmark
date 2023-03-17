
app <- "rna.roc.plot.R"

args <- commandArgs(T)
if (length(args) < 7) {
  msg <- sprintf("Usage: %s <data dir> <roc suffix> <auc file> <out file> \\
                            <title> <table xmin> <table ymin>", app)
  write(msg, file = stderr())
  quit("no", 1) 
}

data_dir <- args[1]
roc_suffix <- args[2]
auc_fn <- args[3]
out_fn <- args[4]
title <- args[5]
xmin <- as.numeric(args[6])
ymin <- as.numeric(args[7])

set.seed(123)

library(ggplot2)
library(gridExtra)

auc <- read.table(auc_fn, sep = "\t", header = T, stringsAsFactors = F)
auc$auc <- round(auc$auc, 3)

data <- NULL
for (fn in dir(data_dir, pattern = roc_suffix)) {
  fpath <- paste0(data_dir, "/", fn)
  method <- strsplit(fn, ".", fixed = T)[[1]][6]
  roc <- readRDS(fpath)  # object returned by cardelino::binaryROC()
  d <- roc$df
  d$method <- method
  data <- rbind(data, d)
}

p <- ggplot() +
  geom_line(data = data,
            aes(x = FPR, y = TPR, color = method, group = method)) +
  labs(x = "False Positive Rate", 
       y = "True Positive Rate", 
       title = title,
       color = "Method") +
  theme(plot.title = element_text(size=22)) +
  annotation_custom(tableGrob(auc, rows=NULL), 
                    xmin = xmin, ymin = ymin)

jpeg(out_fn, height=3000, width=3500, res=500)
p
dev.off()

print(paste0("[", app, "] All Done!"))

