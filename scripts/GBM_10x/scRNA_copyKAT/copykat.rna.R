
app <- "copykat.rna.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <sample id> <matrix dir> \\
                                  <cell anno file> <control cell type> \\
                                  <number of cores> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
matrix_dir <- args[2]
cell_anno_fn <- args[3]
control_cell_type <- args[4]
ncores <- as.numeric(args[5])
out_dir <- args[6]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

# run Seurat
library(Seurat)
raw.data <- Read10X(data.dir = matrix_dir)
raw.data <- CreateSeuratObject(counts = raw.data, project = sid, 
                               min.cells = 0, min.features = 0)

exp_raw_mtx <- as.matrix(raw.data@assays$RNA@counts)
saveRDS(exp_raw_mtx, file = paste0(out_dir, '/', sid, '.gex.rds'))

## run copykat
library(copykat)

control <- ""
if (control_cell_type != "NULL") {
  cell_anno <- read.table(cell_anno_fn, sep = "\t", header = F, stringsAsFactors = F)
  colnames(cell_anno) <- c("cell", "cell_type")
  control <- cell_anno$cell[cell_anno$cell_type == control_cell_type]
}

copykat_obj <- copykat(rawmat=exp_raw_mtx, id.type="S", 
                       ngene.chr=5, 
                       win.size=25, 
                       KS.cut=0.1, 
                       sam.name=sid, 
                       distance="euclidean", 
                       norm.cell.names=control, 
                       n.cores=ncores)

saveRDS(copykat_obj, paste0(out_dir, '/', sid, '.copykat.obj.init.rds'))

print(paste0("[", app, "] All Done!"))

