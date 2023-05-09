
app <- "numbat.preprocess.expr.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <matrix file> <ref cells file> \\
                                  <ref cell type>    \\
                                  <output dir> <out prefix> <save raw>")
  write(msg, file = stderr())
  quit("no", 1)
}

mtx_fn <- args[1]
ref_cell_fn <- args[2]
ref_cell_type <- args[3]
out_dir <- args[4]
out_prefix <- args[5]
save_raw <- args[6]

set.seed(123)

library(dplyr)

count_mtx <- as.matrix(readRDS(mtx_fn))   # gene x cell
str(count_mtx) 
if (save_raw == "True")
  saveRDS(count_mtx, sprintf("%s/%s.raw.count.mtx.rds", out_dir, out_prefix))

ref_cells <- read.delim(ref_cell_fn, header = T, stringsAsFactors = F)
cnt_mtx1 <- count_mtx[, ! (colnames(count_mtx) %in% ref_cells$cell)]
str(cnt_mtx1)
saveRDS(cnt_mtx1, sprintf("%s/%s.%s_filtered.count.mtx.rds", out_dir, 
                          out_prefix, ref_cell_type))

print(paste0("[", app, "] All Done!"))

