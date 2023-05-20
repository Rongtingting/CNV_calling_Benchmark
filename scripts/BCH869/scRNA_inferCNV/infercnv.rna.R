
app <- "infercnv.rna.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <sample id> <matrix file> \\
                                  <anno file> <ref cell type> \\
                                  <gene file> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
matrix_file <- args[2]
anno_file <- args[3]
ref_cell_type <- args[4]
gene_file <- args[5]
out_dir <- args[6]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)

library(infercnv)

gex <- read.csv(matrix_file, row.names = 1, stringsAsFactors = F)  # gene x cell matrix

#anno <- read.delim(anno_file, stringsAsFactors = F, row.names = 1)

infercnv_obj <- CreateInfercnvObject(
  raw_counts_matrix=gex,
  annotations_file=anno_file,
  delim='\t',
  gene_order_file=gene_file,
  ref_group_names=c(ref_cell_type)
)

infercnv_obj <- infercnv::run(infercnv_obj,
                              cutoff=1,  
                              out_dir=out_dir, 
                              cluster_by_groups=T,
                              denoise=T,
                              HMM=T)

print(paste0("[", app, "] All Done!"))

