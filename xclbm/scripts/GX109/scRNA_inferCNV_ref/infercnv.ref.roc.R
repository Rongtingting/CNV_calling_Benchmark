
app <- "infercnv.ref.roc.R"

args <- commandArgs(T)
if (length(args) < 7) {
  msg <- sprintf("Usage: %s <cnv type> <data dir> <subdir prefix> \\
                            <truth file> <out dir> <out prefix> \\
                            <cutoff max size>", app)
  write(msg, file = stderr())
  quit("no", 1)
}

cnv_type <- args[1]
data_dir <- args[2]
subdir_prefix <- args[3]
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

ref_auc <- c()
ref_name <- c()
i <- 1
for (d in dir(data_dir, pattern = subdir_prefix)) {
  dir <- paste0(data_dir, "/", d)
  if (! dir.exists(dir)) {
    i <- i + 1
    next 
  }

  cell_type = strsplit(d, "_", fixed = T)[[1]][2]

  data_fn = paste0(dir, "/BayesNetOutput.HMMi6.hmm_mode-samples/MCMC_inferCNV_obj.rds")
  print(sprintf("Begin to process cell type '%s'", cell_type))
  dat <- readRDS(data_fn)
  expr <- t(dat@expr.data)   # cell x gene matrix

  # keep the order of cell & gene the same with ground truth matrix
  cells <- truth_cells[truth_cells %in% rownames(expr)]
  genes <- truth_genes[truth_genes %in% colnames(expr)]
  if (length(cells) != length(truth_cells)) {
    stop("some cells in truth matrix are not in expr matrix!")
  }
  if (length(genes) != length(truth_genes)) {
    stop("some genes in truth matrix are not in expr matrix!")
  }

  expr <- expr[cells, genes]
  saveRDS(expr, sprintf("%s.%s.isec.expr.mtx.rds", out_prefix, cell_type))

  if (cnv_type == "loss") {
    expr <- expr * (-1)
  }

  cutoff <- sort(unique(c(expr)))
  if (length(cutoff) > cutoff_max_size) {
     cutoff <- sample(cutoff, size = cutoff_max_size)
  }
  roc <- cardelino::binaryROC(expr, truth, cutoff = cutoff)
  saveRDS(roc, sprintf("%s.%s.cardelino.roc.rds", out_prefix, cell_type))

  ref_auc[i] <- roc$AUC
  ref_name[i] <- cell_type
  i <- i + 1
}

auc <- data.frame(cell_type = ref_name, auc = ref_auc)
write.table(auc, paste0(out_prefix, ".auc.tsv"), sep = "\t",
            quote = F, row.names = F, col.names = T)

print(paste0("[", app, "] All Done!"))

