# GX109.run.fast2.R - benchmark on GX109 dataset

library(cardelino)
library(dplyr)
library(ggplot2)
library(stringr)

source("benchmark.R")
source("utils.R")
source("GX109.R")

sid <- "GX109"
cnv_type <- "copy_gain"    # could be "copy_gain", "copy_loss", or "loh".
cnv_scale <- "gene"        # could be "gene" or "arm".

xclone_dir <- "GX109_xclone/prob_combine_copygain"
roc_fn <- "GX109.copy_gain.gene_scale.roc.pre_plot_dat_list.list.rds"
prc_fn <- "GX109.copy_gain.gene_scale.prc.pre_plot_dat_list.list.rds"
metrics <- c("ROC", "PRC")
metric_fn <- c(roc_fn, prc_fn)

gene_anno_fn <- "annotate_genes_hg38_update.txt"
cell_subset_fn <- "GX109.copy_gain.gene_scale.subset.cells.df.tsv"
gene_subset_fn <- "GX109.copy_gain.gene_scale.subset.genes.df.tsv"
truth_fn <- "GX109.copy_gain.gene_scale.truth.cell_x_gene.binary.mtx.rds"
out_dir <- "result"

bm_GX109_fast2(
  sid, cnv_type, cnv_scale, 
  xclone_dir, metrics, metric_fn,
  gene_anno_fn, 
  cell_subset_fn, gene_subset_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

