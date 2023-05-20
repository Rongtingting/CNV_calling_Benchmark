#!/usr/bin/env Rscript

app <- "copykat.rna.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <sample id> <expression file> \\
                                  <cell anno> <control cell type> \\
                                  <number of cores> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
exp_file <- args[2]
cell_anno_fn <- args[3]
control_cell_type <- args[4]
ncores <- as.numeric(args[5])
out_dir <- args[6]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(copykat)

exp_mtx <- read.csv(exp_file, stringsAsFactor=F, row.names = 1)  # gene x cell matrix
control <- ""
if (control_cell_type != "NULL") {
  cell_anno <- read.delim(cell_anno_fn, header = F, stringsAsFactors = F)
  colnames(cell_anno) <- c("cell_id", "cell_type")
  control <- cell_anno$cell_id[cell_anno$cell_type == control_cell_type]
}

copykat.bc <- copykat(rawmat=exp_mtx, id.type="S", ngene.chr=5, win.size=25, 
                      KS.cut=0.15, sam.name=sid, distance="euclidean", 
                      norm.cell.names=control, n.cores=ncores)
saveRDS(copykat.bc, paste0(out_dir, '/', sid, '.copykat.obj.init.rds'))

print(paste0("[", app, "] All Done!"))

