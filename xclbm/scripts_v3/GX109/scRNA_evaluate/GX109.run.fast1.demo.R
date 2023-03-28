# GX109.run.fast1.R - benchmark on GX109 dataset

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
dat_list_fn <- "GX109.copy_gain.gene_scale.extract.data_list.list.rds"

cell_anno_fn <- "GX109.cell.anno.tsv"
gene_anno_fn <- "annotate_genes_hg38_update.txt"
truth_fn <- "GX109.cnv.ground.truth.tsv"
out_dir <- "result"

cnv_cell_type <- c("Paneth", "TA")

bm_GX109_fast1(
  sid, cnv_type, cnv_scale, 
  xclone_dir, dat_list_fn,
  cell_anno_fn, gene_anno_fn, truth_fn, cnv_cell_type, out_dir,
  overlap_mode = "customize", filter_func = NULL, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

