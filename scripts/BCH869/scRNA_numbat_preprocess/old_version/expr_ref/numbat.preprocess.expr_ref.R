
app <- "numbat.preprocess.expr_ref.R"

args <- commandArgs(T)
if (length(args) < 3) {
  msg <- paste0("Usage: ", app, " <matrix dir> <cell anno> \\
                                  <output file>")
  write(msg, file = stderr())
  quit("no", 1)
}

count_mtx_dir <- args[1]
cell_anno_fn <- args[2]
out_fn <- args[3]

set.seed(123)

library(Seurat)
library(numbat)

count_mtx <- Seurat::Read10X(data.dir = count_mtx_dir)   # gene x cell
str(count_mtx)

anno <- read.delim(cell_anno_fn, header = T, stringsAsFactors = F)
ref_internal <- aggregate_counts(count_mtx, anno)
str(ref_internal)

saveRDS(ref_internal, out_fn)

print(paste0("[", app, "] All Done!"))

