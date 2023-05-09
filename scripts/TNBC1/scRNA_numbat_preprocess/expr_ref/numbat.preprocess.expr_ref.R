
app <- "numbat.preprocess.expr_ref.R"

args <- commandArgs(T)
if (length(args) < 3) {
  msg <- paste0("Usage: ", app, " <matrix file> <cell anno> \\
                                  <output file>")
  write(msg, file = stderr())
  quit("no", 1)
}

mtx_fn <- args[1]
cell_anno_fn <- args[2]
out_fn <- args[3]

set.seed(123)

library(numbat)

count_mtx <- as.matrix(readRDS(mtx_fn))   # gene x cell
str(count_mtx)

anno <- read.delim(cell_anno_fn, header = T, stringsAsFactors = F)
ref_internal <- aggregate_counts(count_mtx, anno)
str(ref_internal)

saveRDS(ref_internal, out_fn)

print(paste0("[", app, "] All Done!"))

