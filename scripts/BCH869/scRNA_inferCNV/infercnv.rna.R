
app <- "infercnv.rna.R"

args <- commandArgs(T)
if (length(args) < 5) {
  msg <- paste0("Usage: ", app, " <sample id> <matrix file> <anno file> \\
                                  <gene file> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
matrix_file <- args[2]
anno_file <- args[3]
gene_file <- args[4]
out_dir <- args[5]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(infercnv)

gex <- read.csv(matrix_file, row.names = 1, stringsAsFactors = F)  # gene x cell matrix

#anno <- read.csv(anno_file, row.names = 1, stringsAsFactors = F)
#anno <- as.data.frame(anno$celltype, stringsAsFactors = F)
#rownames(anno) <- colnames(gex)  # have checked that it's fine

anno <- read.delim(anno_file, stringsAsFactors = F, row.names = 1)
celltype <- c(NA, "Normal")

for (i in celltype) {
  ref <- c(i)
  if (is.na(i)) {
    ref <- c()
    i <- "NULL"
  }
  print(paste0("[", app, "] cell type ", i))

  infercnv_obj <- CreateInfercnvObject(
    raw_counts_matrix=gex,
    annotations_file=anno,
    delim='\t',
    gene_order_file=gene_file,
    ref_group_names=ref
  )

  res_dir <- paste0(out_dir, '/', sid, '_', i)
  
  infercnv_obj <- infercnv::run(infercnv_obj,
                                cutoff=1,  
                                out_dir=res_dir, 
                                cluster_by_groups=T,
                                denoise=T,
                                HMM=T)
}

print(paste0("[", app, "] All Done!"))

