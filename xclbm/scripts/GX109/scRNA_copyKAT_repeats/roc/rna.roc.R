
app <- "rna.roc.R"

args <- commandArgs(T)
if (length(args) < 7) {
  msg <- paste0("Usage: ", app, " <cnv type> <data dir> <expr suffix> \\
                                  <truth file> <out dir> <out prefix> \\
                                  <cutoff max size>")
  write(msg, file = stderr())
  quit("no", 1)
}

cnv_type <- args[1]
data_dir <- args[2]
expr_suffix <- args[3]
truth_fn <- args[4]
out_dir <- args[5]
out_prefix <- args[6]
cutoff_max_size <- as.numeric(args[7])

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(cardelino)

truth <- readRDS(truth_fn)  # cell x gene matrix of binary values
truth_cells <- rownames(truth)   
truth_genes <- colnames(truth)   

method_auc <- c()
method_name <- c()
i <- 1
for (fn in dir(data_dir, pattern = expr_suffix)) {
  fpath <- paste0(data_dir, "/", fn)
  print(sprintf("Begin to process expression file '%s'", fpath))
  method <- strsplit(fn, ".", fixed = T)[[1]][4]
  expr <- readRDS(fpath)   # cell x gene matrix

  cells <- rownames(expr)
  genes <- colnames(expr)
  if (length(truth_cells) != length(cells)) {
    stop("number of cells in truth matrix and expr matrix are different!")
  }
  if (! all(sort(truth_cells) == sort(cells))) {
    stop("some cells in truth matrix and expr matrix are different!")
  }
  if (length(truth_genes) != length(genes)) {
    stop("number of genes in truth matrix and expr matrix are different!")
  }
  if (! all(sort(truth_genes) == sort(genes))) {
    stop("some genes in truth matrix and expr matrix are different!")
  }

  if (cnv_type == "loss") {
    expr <- expr * (-1)
  }

  # keep the order of cell & gene the same with ground truth matrix
  expr <- expr[truth_cells, truth_genes]

  cutoff <- sort(unique(c(expr)))
  if (length(cutoff) > cutoff_max_size) {
     cutoff <- sample(cutoff, size = cutoff_max_size)
  }
  roc <- cardelino::binaryROC(expr, truth, cutoff = cutoff)
  saveRDS(roc, sprintf("%s.%s.cardelino.roc.rds", out_prefix, method))

  method_auc[i] <- roc$AUC
  method_name[i] <- method
  i <- i + 1
}

auc <- data.frame(method = method_name, auc = method_auc)
write.table(auc, paste0(out_prefix, ".auc.tsv"), sep = "\t",
            quote = F, row.names = F, col.names = T)

print(paste0("[", app, "] All Done!"))

