
app <- "casper.rna.R"

args <- commandArgs(T)
if (length(args) < 9) {
  msg <- paste0("Usage: ", app, " <sample id> <matrix dir> <cell anno file> \\
                                  <control cell type> <gene anno file> \\
                                  <hg version> <baf dir> \\
                                  <baf suffix> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
matrix_dir <- args[2]
anno_file <- args[3]
control_cell_type <- args[4]
gene_anno_fn <- args[5]
hg_ver <- as.numeric(args[6])
baf_dir <- args[7]
baf_suffix <- args[8]
out_dir <- args[9]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(Seurat)
library(CaSpER)

if (hg_ver == 19) {
  data("hg19_cytoband")
  cytoband1 <- cytoband
  centromere1 <- centromere
  is_hg19 <- T
} else if (hg_ver == 38) {
  data("hg38_cytoband")
  cytoband1 <- cytoband_hg38
  centromere1 <- centromere_hg38
  is_hg19 <- F
} else {
  stop("hg version should be either 19 or 38!")
}

gex <- Seurat::Read10X(data.dir = matrix_dir)
obj <- CreateSeuratObject(counts = gex, project = sid,
                          min.cells = 3, min.features = 200)
obj <- NormalizeData(obj, scale.factor = 1e6, normalization.method = "RC")
obj <- FindVariableFeatures(obj, do.plot = T, nfeatures = 1000)
obj <- ScaleData(obj)
log.ge <- as.matrix(obj@assays$RNA@data)   # a gene x barcode matrix

#select control cell type
anno <- read.delim(anno_file, stringsAsFactors = F, header = F)
colnames(anno) <- c("cell", "cell_type")
print(str(anno))
control <- anno$cell[anno$cell_type == control_cell_type]
print(str(control))

genes <- rownames(log.ge)
if (file.exists(gene_anno_fn)) {
  annotation <- readRDS(gene_anno_fn)
} else {
  annotation <- generateAnnotation(id_type="hgnc_symbol", genes=genes, 
                                   centromere=centromere1, ishg19=is_hg19)
  saveRDS(annotation, gene_anno_fn)
}
#log.ge <- log.ge[match(annotation$Gene, genes), ]
log.ge <- log.ge[genes %in% annotation$Gene, ]
log.ge <- log2(log.ge + 1)

loh <- readBAFExtractOutput(path = baf_dir, sequencing.type = "scRNA", 
                            suffix = baf_suffix)
names(loh)[1] <- sid
loh.name.mapping <- data.frame(loh.name = sid, sample.name=colnames(log.ge))

object <- CreateCasperObject(raw.data=log.ge, 
                             loh.name.mapping=loh.name.mapping, 
                             sequencing.type="single-cell", 
                             cnv.scale=3, loh.scale=3, 
                             expr.cutoff=0.1, filter="median", 
                             matrix.type="normalized",
                             annotation=annotation, method="iterative", loh=loh, 
                             control.sample.ids=control, cytoband=cytoband1)

saveRDS(object, paste0(out_dir, "/", sid, ".object.rds"))

final.objects <- runCaSpER(object, removeCentromere=T, 
                           cytoband=cytoband1, method="iterative")

## summarize large scale events 
final_chr_mat <- extractLargeScaleEvents(final.objects, thr=0.75) 
saveRDS(final_chr_mat, paste0(sid, ".final_chr_mat.rds"))

saveRDS(final.objects[[1]]@loh.median.filtered.data, 
        paste0(sid, ".loh.median.filtered.data.rds"))  # for plotting

obj <- final.objects[[9]]
saveRDS(obj, paste0(out_dir, "/", sid, ".object.scale.rds"))

saveRDS(final.objects, paste0(out_dir, "/", sid, ".final.objects.rds"))

plotHeatmap10x(object=obj, fileName=paste0(out_dir, "/", sid, ".heatmap.png"),
               cnv.scale=3, cluster_cols=F, cluster_rows=T, 
               show_rownames=F, only_soi=T)

plotHeatmap10x(object=obj, 
               fileName=paste0(out_dir, "/", sid, ".all.cells.heatmap.png"),
               cnv.scale=3, cluster_cols=F, cluster_rows=T, 
               show_rownames=F, only_soi=F)

print(paste0("[", app, "] All Done!"))

