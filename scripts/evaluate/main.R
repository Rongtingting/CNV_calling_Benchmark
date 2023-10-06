# main.R

# Notes:
# 1. several functions should be imported from `benchmark.R`:
#    - run_benchmark, run_bm_fast.
#    - run_extract, save_extract.
# 2.  several functions should be imported from `utils.R`:
#    - flush_print, str_now.
#    - load_gene_anno.


#' Benchmark main function
#' @inheritParams run_benchmark
#' @param method_list A string vector. Names of methods.
#' @param method_sub_list A string vector. Names of sub-type methods.
#' @param mtx_type_list A string vector. Matrix type could be "baf", 
#'   "expr" or "prob".
#' @param dat_dir_list A string vector. Data dir of each method.
#' @param cell_anno_fn A string. Path to cell annotation file. It is a TSV
#'   file containing 2 columns (without header) cell and cell_type.
#' @param gene_anno_fn A string. Path to gene annotation file. It is a TSV
#'   file downloaded from XClone repo whose first 5 columns are 
#'   GeneName, GeneID, chr, start, stop.
#' @param truth_fn A string. Path to ground truth file. It is a TSV file
#'   containing at least 5 columns chrom, start, end, clone (or cell_type), 
#'   cnv_type.
#' @return A ggplot2 object. The ROC plot.
bm_main <- function(
  sid, cnv_type, cnv_scale, 
  method_list, method_sub_list, mtx_type_list, dat_dir_list,
  cell_anno_fn, gene_anno_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = FALSE, save_all = FALSE)
{
  func <- "bm_main"

  flush_print(sprintf("[I::%s][%s] start now ...", func, str_now()))

  prefix <- sprintf("%s.%s.%s_scale", sid, cnv_type, cnv_scale)

  # load data
  flush_print(sprintf("[I::%s][%s] load input data ...", func, str_now()))

  cell_anno <- read.delim(cell_anno_fn, header = F, stringsAsFactors = F)
  colnames(cell_anno) <- c("cell", "cell_type")
  if (verbose)
    str(cell_anno)

  gene_anno <- load_gene_anno(gene_anno_fn)
  if (verbose)
    str(gene_anno)

  truth_region <- read.delim(truth_fn, header = T, stringsAsFactors = F)
  if (any(! truth_region$cnv_type %in% c("gain", "loss", "loh")))
    stop(sprintf("[E::%s] cnv type should be 'gain', 'loss' or 'loh'.", func))
  idx <- truth_region$cnv_type %in% c("gain", "loss")
  truth_region$cnv_type[idx] <- paste0("copy_", truth_region$cnv_type[idx])
  truth_region <- truth_region %>% 
    dplyr::mutate(chrom = stringr::str_remove(chrom, "chr"))

  if (sid == "BCH869")
    truth_region <- truth_region %>%
      dplyr::rename(cell_type = clone)
  else if (sid == "GBM_10x")
    truth_region <- truth_region %>%
      dplyr::rename(cell_type = clone)

  truth <- truth_region
  if (verbose)
    str(truth)

  # extract matrices
  flush_print(sprintf("[I::%s][%s] extract matrices ...", func, str_now()))

  dat_list <- run_extract(
    sid, cnv_type, cnv_scale, gene_anno,
    method_list, method_sub_list, mtx_type_list, dat_dir_list,
    verbose = verbose)

  if (sid == "BCH869") {
    i <- 1
    for (dat in dat_list) {
      cells <- rownames(dat$mtx)
      cells <- stringr::str_replace(cells, "BT_", "BCH")
      cells <- stringr::str_replace_all(cells, "-", ".")
      rownames(dat$mtx) <- cells
      dat_list[[i]] <- dat
      i <- i + 1
    }
  }

  if (verbose)
    str(dat_list)

  dir_extract <- sprintf("%s/s1_extract", out_dir)
  save_extract(dat_list, dir_extract, prefix, save_all)
  flush_print(sprintf("[I::%s][%s] extracted data is saved to dir '%s'.", func,
              str_now(), dir_extract))

  # benchmark core part
  flush_print(sprintf("[I::%s][%s] benchmark core part ...", func, str_now()))

  res_bm <- run_benchmark(
    sid, cnv_type, cnv_scale,
    dat_list, cell_anno, gene_anno, truth, out_dir,
    overlap_mode, filter_func, 
    metrics, max_n_cutoff,
    plot_dec, plot_legend_xmin, plot_legend_ymin,
    plot_width, plot_height, plot_dpi,
    verbose, save_all
  )

  return(res_bm)
}


#' Fast Benchmark (Scenario 1)
#' Fast benchmark when matrices of other methods have been extracted while
#' XClone outputs new cells or genes, which means the step `overlap` should
#' be re-run.
#' @inheritParams bm_main
#' @param xclone_dir A string. Path to XClone data dir.
#' @param dat_list_fn A string. Path to the file containing a list of extracted
#'   matrices data, returned by `run_extract`.
#' @return A ggplot2 object. The ROC plot.
bm_main_fast1 <- function(
  sid, cnv_type, cnv_scale, 
  xclone_dir, dat_list_fn,
  cell_anno_fn, gene_anno_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, 
  metrics = c("ROC", "PRC"), max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = FALSE, save_all = FALSE)
{
  func <- "bm_main_fast1"

  flush_print(sprintf("[I::%s][%s] start now ...", func, str_now()))

  prefix <- sprintf("%s.%s.%s_scale", sid, cnv_type, cnv_scale)

  # load data
  flush_print(sprintf("[I::%s][%s] load input data ...", func, str_now()))

  cell_anno <- read.delim(cell_anno_fn, header = F, stringsAsFactors = F)
  colnames(cell_anno) <- c("cell", "cell_type")
  if (verbose)
    str(cell_anno)

  gene_anno <- load_gene_anno(gene_anno_fn)
  if (verbose)
    str(gene_anno)

  truth_region <- read.delim(truth_fn, header = T, stringsAsFactors = F)
  if (any(! truth_region$cnv_type %in% c("gain", "loss", "loh")))
    stop(sprintf("[E::%s] cnv type should be 'gain', 'loss' or 'loh'.", func))
  idx <- truth_region$cnv_type %in% c("gain", "loss")
  truth_region$cnv_type[idx] <- paste0("copy_", truth_region$cnv_type[idx])
  truth_region <- truth_region %>% 
    dplyr::mutate(chrom = stringr::str_remove(chrom, "chr"))

  if (sid == "BCH869")
    truth_region <- truth_region %>%
      dplyr::rename(cell_type = clone)
  else if (sid == "GBM_10x")
    truth_region <- truth_region %>%
      dplyr::rename(cell_type = clone)

  truth <- truth_region
  if (verbose)
    str(truth)

  # extract matrices
  flush_print(sprintf("[I::%s][%s] extract XClone matrices ...", 
                      func, str_now()))

  xclone_dat_list <- run_extract(
    sid, cnv_type, cnv_scale, gene_anno,
    c("xclone"), c("xclone"), c("prob"), c(xclone_dir), verbose)

  xclone_dat <- xclone_dat_list[[1]]

  if (sid == "BCH869") {
    cells <- rownames(xclone_dat$mtx)
    cells <- stringr::str_replace(cells, "BT_", "BCH")
    cells <- stringr::str_replace_all(cells, "-", ".")
    rownames(xclone_dat$mtx) <- cells
  }

  if (verbose)
    str(xclone_dat)

  # merge data
  flush_print(sprintf("[I::%s][%s] merge matrices data ...", 
                      func, str_now()))

  dat_list <- readRDS(dat_list_fn)
  i <- 1
  for (dat in dat_list) {
    if (dat$method == "xclone") {
      dat_list[[i]] <- xclone_dat
      break
    }
    i <- i + 1
  }
  if (i > length(dat_list))
    dat_list[[i]] <- xclone_dat

  if (verbose)
    str(dat_list)

  dir_extract <- sprintf("%s/s1_extract", out_dir)
  save_extract(dat_list, dir_extract, prefix, save_all)
  flush_print(sprintf("[I::%s][%s] extracted data is saved to dir '%s'.", func,
              str_now(), dir_extract))

  # benchmark core part
  flush_print(sprintf("[I::%s][%s] benchmark core part ...", func, str_now()))

  res_bm <- run_benchmark(
    sid, cnv_type, cnv_scale,
    dat_list, cell_anno, gene_anno, truth, out_dir,
    overlap_mode, filter_func, 
    metrics, max_n_cutoff,
    plot_dec, plot_legend_xmin, plot_legend_ymin,
    plot_width, plot_height, plot_dpi,
    verbose, save_all
  )

  return(res_bm)
}


#' Fast Benchmark (Scenario 2)
#' Fast benchmark when overlap cells and genes are provided and XClone does 
#' not output new cells or genes.
#' @inheritParams bm_main
#' @inheritParams run_bm_fast
#' @param xclone_dir A string. Path to XClone data dir.
#' @return A ggplot2 object. The ROC plot.
bm_main_fast2 <- function(
  sid, cnv_type, cnv_scale, 
  xclone_dir, metrics, metric_fn,
  gene_anno_fn,
  cell_subset_fn, gene_subset_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, max_n_cutoff = 1000,
  plot_dec = 3, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = FALSE, save_all = FALSE)
{
  func <- "bm_main_fast2"

  flush_print(sprintf("[I::%s][%s] start now ...", func, str_now()))

  prefix <- sprintf("%s.%s.%s_scale", sid, cnv_type, cnv_scale)

  # load data
  flush_print(sprintf("[I::%s][%s] load input data ...", func, str_now()))

  gene_anno <- load_gene_anno(gene_anno_fn)
  if (verbose)
    str(gene_anno)

  # extract matrices
  flush_print(sprintf("[I::%s][%s] extract XClone matrices ...", 
                      func, str_now()))

  xclone_dat_list <- run_extract(
    sid, cnv_type, cnv_scale, gene_anno,
    c("xclone"), c("xclone"), c("prob"), c(xclone_dir), verbose)

  xclone_dat <- xclone_dat_list[[1]]
  xclone_mtx <- xclone_dat$mtx

  if (sid == "BCH869") {
    cells <- rownames(xclone_mtx)
    cells <- stringr::str_replace(cells, "BT_", "BCH")
    cells <- stringr::str_replace_all(cells, "-", ".")
    rownames(xclone_mtx) <- cells
  }

  if (verbose)
    str(xclone_dat)

  # benchmark core part
  flush_print(sprintf("[I::%s][%s] benchmark core part ...", func, str_now()))

  res_bm <- run_bm_fast(
    sid, cnv_type, cnv_scale,
    xclone_mtx, metrics, metric_fn,
    cell_subset_fn, gene_subset_fn, truth_fn, out_dir,
    max_n_cutoff,
    plot_dec, plot_legend_xmin, plot_legend_ymin,
    plot_width, plot_height, plot_dpi,
    verbose, save_all) 

  return(res_bm)
}


construct_truth <- function(truth_region, cnv_cell_type) {
  truth <- NULL
  for (ct in cnv_cell_type)
    truth <- rbind(truth, cbind(truth_region, ct))
  truth <- truth %>% dplyr::rename(cell_type = ct)
  return(truth)
}

