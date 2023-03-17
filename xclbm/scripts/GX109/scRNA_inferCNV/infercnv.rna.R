#################
##HUANG Rongting
##2021-06-07
#################

app <- "infercnv.rna.R"

args <- commandArgs(T)
if (length(args) < 5) {
  msg <- paste0("Usage: ", app, " <sample id> <matrix dir> <anno file> \\
                                  <gene file> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
matrix_dir <- args[2]
anno_file <- args[3]
gene_file <- args[4]
out_dir <- args[5]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(Seurat)
library(infercnv)

### read count matrix
gex_mtx <- Seurat::Read10X(data.dir = matrix_dir)

### parse cell types
anno <- read.table(anno_file, sep = "\t", header = F, stringsAsFactors = F)
colnames(anno) <- c("cell", "cell_type")
celltype <- c(NA, unique(anno$cell_type))

### run inferCNV with loop
for (i in celltype) {
  ref <- c(i)
  if (is.na(i)) {
    ref <- c()
    i <- "NULL"
  }
  print(paste0("[", app, "] cell type ", i))
  infercnv_obj1 <- CreateInfercnvObject(raw_counts_matrix=gex_mtx,
                                        annotations_file=anno_file,
                                        delim='\t',
                                        gene_order_file=gene_file,
                                        ref_group_names=ref)

  res_dir <- paste0(out_dir, '/', sid, '_', i)
  
  infercnv_obj1 <- infercnv::run(infercnv_obj1,
                                 cutoff=0.1,  
                                 out_dir=res_dir, 
                                 cluster_by_groups=T,   
                                 denoise=T,
                                 HMM=T)
}

print(paste0("[", app, "] All Done!"))

