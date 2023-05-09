# GX109.run.R - benchmark on GX109 dataset

library(cardelino)
library(dplyr)
library(ggplot2)
library(stringr)

source("benchmark.R")
source("main.R")
source("utils.R")

sid <- "GX109"
cnv_type <- "copy_gain"    # could be "copy_gain", "copy_loss", or "loh".
cnv_scale <- "gene"        # could be "gene" or "arm".

method_list <- c("casper", "copykat", "infercnv", "numbat", "xclone")
method_sub_list <- c("casper", "copykat", "infercnv", "numbat", "xclone")
mtx_type_list <- c("expr", "expr", "expr", "prob", "prob")
dat_dir_list <- c(
  "GX109_casper",
  "GX109_copykat",
  "GX109_infercnv",
  "GX109_numbat",
  "GX109_xclone/prob_combine_copygain"
)

# or, for BAF
#method_list <- c("casper", "casper", "numbat", "xclone")
#method_sub_list <- c("casper_median", "casper_medianDev", "numbat", "xclone")
#mtx_type_list <- c("baf", "baf", "prob", "prob")
#dat_dir_list <- c(
#  "GX109_casper",
#  "GX109_casper",
#  "GX109_numbat",
#  "GX109_xclone/prob_combine_loh"
#)

cell_anno_fn <- "GX109-T1c_scRNA_annotation_2column.tsv"
gene_anno_fn <- "annotate_genes_hg38_update.txt"
truth_fn <- "GX109.cnv.ground.truth.with_celltype.tsv"
out_dir <- "result"

bm_main(
  sid, cnv_type, cnv_scale, 
  method_list, method_sub_list, mtx_type_list, dat_dir_list,
  cell_anno_fn, gene_anno_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 4, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

