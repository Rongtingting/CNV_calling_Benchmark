# BCH869.run.fast1.filter.R - benchmark on BCH869 dataset

library(cardelino)
library(dplyr)
library(ggplot2)
library(stringr)

source("benchmark.R")
source("main.R")
source("utils.R")

sid <- "BCH869"
cnv_type <- "copy_gain"    # could be "copy_gain", "copy_loss", or "loh".
cnv_scale <- "gene"        # could be "gene" or "arm".

xclone_dir <- "BCH869_xclone/prob_combine_copygain"
dat_list_fn <- "BCH869.copy_gain.gene_scale.extract.data_list.list.rds"

cell_anno_fn <- "BCH869.492.cell.clone.anno.tsv"
gene_anno_fn <- "annotate_genes_hg19_update.txt"
truth_fn <- "BCH869.cnv.ground.truth.clean.0316.tsv"
out_dir <- "result"

filter_chr1719 <- function(cells, genes) {
  filter_regions <- c("chr17:41865689", "chr19:-16857901")
  filter_regions <- parse_regions(filter_regions)
  filter_regions <- filter_regions %>%
    dplyr::mutate(reg_id = sprintf("%s:%s-%s", chrom, start, end))
  res_overlap <- overlap_gene_anno(filter_regions, genes)
  gene_overlap <- res_overlap$gene_overlap
  genes <- genes[! genes$Gene %in% gene_overlap$Gene, ]
  return(list(cells = cells, genes = genes))
}

bm_main_fast1(
  sid, cnv_type, cnv_scale, 
  xclone_dir, dat_list_fn,
  cell_anno_fn, gene_anno_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = filter_chr1719, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

