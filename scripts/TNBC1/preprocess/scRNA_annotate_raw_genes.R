
app <- "scRNA_annotate_raw_genes.R"

args <- commandArgs(T)
if (length(args) < 3) {
  msg <- paste0("Usage: ", app, " <input gene list> <hg version> \\
                                  <output anno file>")
  write(msg, file = stderr())
  quit("no", 1)
}

gene_fn <- args[1]
hg_ver <- as.numeric(args[2])
anno_fn <- args[3]

set.seed(123)

library(CaSpER)

if (hg_ver == 19) {
  data("hg19_cytoband")
  centromere1 <- centromere
  is_hg19 <- T
} else if (hg_ver == 38) {
  data("hg38_cytoband")
  centromere1 <- centromere_hg38
  is_hg19 <- F
} else {
  stop("hg version should be either 19 or 38!")
}

genes <- read.delim(gene_fn, header = F, stringsAsFactors = F)
genes <- genes$V1
annotation <- generateAnnotation(id_type="hgnc_symbol", genes=genes, 
                                 centromere=centromere1, ishg19=is_hg19)
saveRDS(annotation, anno_fn)

print(paste0("[", app, "] All Done!"))

