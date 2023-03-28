# BCH869.run.R - benchmark on BCH869 dataset

library(cardelino)
library(dplyr)
library(ggplot2)
library(stringr)

source("benchmark.R")
source("utils.R")
source("BCH869.R")

sid <- "BCH869"
cnv_type <- "copy_gain"    # could be "copy_gain", "copy_loss", or "loh".
cnv_scale <- "gene"        # could be "gene" or "arm".

method_list <- c("casper", "copykat", "infercnv", "numbat", "xclone")
method_sub_list <- c("casper", "copykat", "infercnv", "numbat", "xclone")
mtx_type_list <- c("expr", "expr", "expr", "prob", "prob")
dat_dir_list <- c(
  "BCH869_casper_normal_492",
  "BCH869_copykat_normal_492",
  "BCH869_infercnv_492/BCH869_Normal",
  "BCH869_numbat",
  "BCH869_xclone/prob_combine_copygain"
)

# or for BAF
#method_list <- c("casper", "casper", "numbat", "xclone")
#method_sub_list <- c("casper_median", "casper_medianDev", "numbat", "xclone")
#mtx_type_list <- c("baf", "baf", "prob", "prob")
#dat_dir_list <- c(
#  "BCH869_casper_normal_492",
#  "BCH869_casper_normal_492",
#  "BCH869_numbat",
#  "BCH869_xclone/prob_combine_loh"
#)

cell_anno_fn <- "BCH869.492.cell.clone.anno.tsv"
gene_anno_fn <- "annotate_genes_hg19_update.txt"
truth_fn <- "BCH869.cnv.ground.truth.clean.0316.tsv"
out_dir <- "result"

bm_BCH869(
  sid, cnv_type, cnv_scale, 
  method_list, method_sub_list, mtx_type_list, dat_dir_list,
  cell_anno_fn, gene_anno_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

