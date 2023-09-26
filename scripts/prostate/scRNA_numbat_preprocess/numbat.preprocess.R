
app <- "numbat.preprocess.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <allele file> <matrix dir>  \\
                                  <cell anno file> <ref cell type>  \\
                                  <output dir> <out prefix>")
  write(msg, file = stderr())
  quit("no", 1)
}

ale_fn <- args[1]
count_mtx_dir <- args[2]
cell_anno_fn <- args[3]
ref_cell_type <- args[4]
out_dir <- args[5]
out_prefix <- args[6]


library(Seurat)
library(numbat)

# filter ref cells from allele dataframe
ale <- read.delim(ale_fn, header = T, stringsAsFactors = F)
str(ale) 

cell_anno <- read.delim(cell_anno_fn, header = F, stringsAsFactors = F)
colnames(cell_anno) <- c("cell", "group")
ref_cells <- cell_anno[cell_anno$group %in% ref_cell_type, ]
str(ref_cells)

ale1 <- ale[! (ale$cell %in% ref_cells$cell), ]
str(ale1)
saveRDS(ale1, sprintf("%s/%s.ref_filtered.allele.dataframe.rds", out_dir, 
                          out_prefix))

# filter ref cells from count matrix
count_mtx <- Seurat::Read10X(data.dir = count_mtx_dir)   # gene x cell
str(count_mtx)

cnt_mtx1 <- count_mtx[, ! (colnames(count_mtx) %in% ref_cells$cell)]
str(cnt_mtx1)
saveRDS(cnt_mtx1, sprintf("%s/%s.ref_filtered.count.mtx.rds", out_dir,
                          out_prefix))

# calculate average expression of ref cells
ref_mean_expr <- numbat::aggregate_counts(count_mtx, ref_cells)
str(ref_mean_expr)
saveRDS(ref_mean_expr, sprintf("%s/%s.ref.gene_by_celltype.mtx.rds",
                               out_dir, out_prefix))

print(paste0("[", app, "] All Done!"))

