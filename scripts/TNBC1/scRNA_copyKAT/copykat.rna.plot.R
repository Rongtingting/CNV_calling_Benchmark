#!usr/bin/env Rscript

app <- "copykat.rna.plot.R"

args <- commandArgs(T)
if (length(args) < 3) {
  msg <- paste0("Usage: ", app, " <sample id> <copykat object> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
object_fn <- args[2]
out_dir <- args[3]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(copykat)

copykat.bc <- readRDS(object_fn)

## BLOCK-1::
##   below codes are modified from the copykat doc on github
pred.test <- data.frame(copykat.bc$prediction)
CNA.test <- data.frame(copykat.bc$CNAmat)

#navigate prediction results
my_palette <- colorRampPalette(
                rev(RColorBrewer::brewer.pal(n = 3, name = "RdBu"))
              )(n = 999)
chr <- as.numeric(CNA.test$chrom) %% 2 + 1
rbPal1 <- colorRampPalette(c('black', 'grey'))
CHR <- rbPal1(2)[as.numeric(chr)]
chr1 <- cbind(CHR, CHR)

rbPal5 <- colorRampPalette(
            RColorBrewer::brewer.pal(n = 8, name = "Dark2")[2:1]
          )
com.preN <- pred.test$copykat.pred
pred <- rbPal5(2)[as.numeric(factor(com.preN))]

cells <- rbind(pred, pred)
col_breaks = c(seq(-1, -0.4, length=50), seq(-0.4, -0.2, length=150),
               seq(-0.2, 0.2, length=600), seq(0.2, 0.4, length=150),
               seq(0.4, 1, length=50))

jpeg(paste0(sid, ".copykat.all.cells.cluster.jpg"), height=2500, 
     width=4000, res=500)
heatmap.3(t(CNA.test[, 4:ncol(CNA.test)]), dendrogram="r", 
          distfun = function(x) {
            parallelDist::parDist(x,threads =4, method = "euclidean")
          }, 
          hclustfun = function(x) {
            hclust(x, method="ward.D2")
          },
          ColSideColors=chr1, RowSideColors=cells, Colv=NA, Rowv=TRUE,
          notecol="black", col=my_palette, breaks=col_breaks, key=TRUE,
          keysize=1, density.info="none", trace="none",
          cexRow=0.1, cexCol=0.1, cex.main=1, cex.lab=0.1,
          symm=F, symkey=F, symbreaks=T, cex=1, cex.main=4, margins=c(10,10)
         )

legend("topright", paste("pred.", names(table(com.preN)), sep=""), 
       pch=15, col=RColorBrewer::brewer.pal(n = 8, name = "Dark2")[2:1],
       cex=0.6, bty="n")
dev.off()

#define subpopulations of aneuploid tumor cells
tumor.cells <- pred.test$cell.names[which(pred.test$copykat.pred == "aneuploid")]
tumor.mat <- CNA.test[, which(colnames(CNA.test) %in% tumor.cells)]
hcc <- hclust(parallelDist::parDist(
                t(tumor.mat), threads=ncores, method="euclidean"
              ), method = "ward.D2")
hc.umap <- cutree(hcc, 2)

rbPal6 <- colorRampPalette(RColorBrewer::brewer.pal(n = 8, name = "Dark2")[3:4])
subpop <- rbPal6(2)[as.numeric(factor(hc.umap))]
cells <- rbind(subpop, subpop)

jpeg(paste0(sid, ".copykat.tumor.cells.cluster.jpg"), height=2500, 
     width=4000, res=500)
heatmap.3(t(tumor.mat), dendrogram="r", 
          distfun=function(x) {
            parallelDist::parDist(x, threads = ncores, method = "euclidean")
          },
          hclustfun=function(x) {
            hclust(x, method="ward.D2")
          },
          ColSideColors=chr1, RowSideColors=cells, Colv=NA, Rowv=TRUE,
          notecol="black", col=my_palette, breaks=col_breaks, key=TRUE,
          keysize=1, density.info="none", trace="none",
          cexRow=0.1, cexCol=0.1, cex.main=1, cex.lab=0.1,
          symm=F, symkey=F, symbreaks=T, 
          cex=1, cex.main=4, margins=c(10,10))

legend("topright", c("c1", "c2"), pch=15, 
       col=RColorBrewer::brewer.pal(n = 8, name = "Dark2")[3:4], 
       cex=0.9, bty='n')
dev.off()

## END BLOCK-1

print(paste0("[", app, "] All Done!"))

