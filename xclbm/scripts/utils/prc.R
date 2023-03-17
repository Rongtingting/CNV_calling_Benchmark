
#' Calculate PRCs
#' @param dat_list A list of CNV baf/expr/prob data for each method, see 
#'   `run_overlap` or `run_subset` for details.
#' @param truth_mtx A cell x gene binary matrix of CNV ground truth, see
#'   `run_truth` for details.
#' @param max_n_cutoff An integer. Maximum number of sampled cutoff values.
#' @param strict A bool. Whether to raise error when cell or genes in truth
#'   and method matrices are different. 
#' @param verbose A bool. Whether to output detailed information.
#' @return A list of updated CNV baf/expr/prob data.
run_prc <- function(dat_list, truth_mtx, max_n_cutoff = 1000, strict = TRUE, 
                    verbose = FALSE) 
{
  func <- "run_prc"

  truth_cells <- rownames(truth_mtx)
  truth_genes <- colnames(truth_mtx)

  new_dat_list <- list()

  set.seed(123)

  for (i in 1:length(dat_list)) {
    dat <- dat_list[[i]]
    mtx <- dat$mtx
    cells <- rownames(mtx)
    genes <- colnames(mtx)
    dat_id <- sprintf("%s-%s", dat$method_sub, dat$mtx_type)

    if (verbose)
      flush_print(sprintf("[I::%s] begin to process %s.", func, dat_id))

    if (length(truth_cells) != length(cells)) {
      if (strict)
        stop(sprintf("[E::%s] #cells in truth and %s matrix: %d, %d",
                     func, dat_id, length(truth_cells), length(cells)))
      flush_print(sprintf("[I::%s] #cells in truth and %s matrix: %d, %d",
                    func, dat_id, length(truth_cells), length(cells)))
      if (! all(truth_cells %in% cells))
        stop(sprintf("[E::%s] some truth-cells are not in %s matrix!", 
                     func, dat_id))
      mtx <- mtx[truth_cells, ]
      cells <- rownames(mtx)
    }

    if (! all(sort(truth_cells) == sort(cells))) {
      stop(sprintf(
        "[E::%s] some cells in truth and %s matrix are different!", 
          func, dat_id))
    }

    if (length(truth_genes) != length(genes)) {
      if (strict)
        stop(sprintf("[E::%s] #genes in truth and %s matrix: %d, %d",
                     func, dat_id, length(truth_cells), length(cells)))
      flush_print(sprintf("[I::%s] #genes in truth and %s matrix: %d, %d",
                    func, dat_id, length(truth_genes), length(genes)))
      if (! all(truth_genes %in% genes))
        stop(sprintf("[E::%s] some truth-genes are not in %s matrix!", 
                     func, dat_id))
      mtx <- mtx[, truth_genes]
      genes <- colnames(mtx)
    }

    if (! all(sort(truth_genes) == sort(genes))) {
      stop(sprintf(
        "[E::%s] some genes in truth and %s matrix are different!", 
          func, dat_id))
    }

    if (dat$mtx_type == "expr" && dat$cnv_type == "copy_loss") {
      mtx <- mtx * (-1)
    }

    # keep the order of cell & gene the same with ground truth matrix
    mtx <- mtx[truth_cells, truth_genes]

    if (verbose) {
      flush_print(sprintf("[I::%s] dim of final %s matrix:", func, dat_id))
      flush_print(dim(mtx))
    }

    cutoff <- base::sort(base::unique(c(mtx)))
    if (length(cutoff) > max_n_cutoff)
      cutoff <- sample(cutoff, size = max_n_cutoff)
    cutoff <- sort(cutoff)
    prc <- cardelino::binaryPRC(mtx, truth_mtx, cutoff = cutoff, add_cut1 = TRUE)
      
    if (verbose) {
      flush_print(sprintf("[I::%s] AUC = %f.", func, prc$AUC))
    }

    dat$mtx <- mtx
    dat$prc <- prc 
    dat$auc <- prc$AUC
    new_dat_list[[i]] <- dat
  }
  return(new_dat_list)
}


save_prc <- function(dat_list, out_dir, prefix, save_all = FALSE) {
  if (! dir.exists(out_dir))
    dir.create(out_dir, recursive = TRUE)

  auc <- data.frame(
    method = sapply(dat_list, "[[", "method"),
    method_sub = sapply(dat_list, "[[", "method_sub"),
    mtx_type = sapply(dat_list, "[[", "mtx_type"),
    auc = sapply(dat_list, "[[", "auc"),
    stringsAsFactors = FALSE
  )
  auc_fn <- sprintf("%s/%s.prc.auc.df.tsv", out_dir, prefix)
  write_tsv(auc, auc_fn)
    
  i <- 1
  for (dat in dat_list) {
    mtx_fn <- sprintf("%s/%s.%s.%s.%s.%s_scale.prc.cell_x_gene.mtx.rds", 
      out_dir, dat$sid, dat$cnv_type, dat$method_sub, dat$mtx_type, 
      dat$cnv_scale)
    if (save_all && ! is.null(dat$mtx))
      saveRDS(dat$mtx, mtx_fn)
    #dat_list[[i]]$mtx <- NULL

    prc_fn <- sprintf("%s/%s.%s.%s.%s.%s_scale.prc.cardelino_cutoff.prc.rds", 
      out_dir, dat$sid, dat$cnv_type, dat$method_sub, dat$mtx_type, 
      dat$cnv_scale)
    saveRDS(dat$prc, prc_fn)

    i <- i + 1
  }

  dat_fn <- sprintf("%s/%s.prc.pre_plot_dat_list.list.rds", out_dir, prefix)
  saveRDS(dat_list, dat_fn)
}


#' Plot PRCs
#' @param dat_list A list of CNV baf/expr/prob data for each method, 
#'   returned by `run_prc`.
#' @param dec An integer. Number of decimal places for AUC.
#' @param title A string. Title of figure.
#' @param legend_xmin A float. The xmin position of legend.
#' @param legend_ymin A float. The ymin position of legend.
#' @param method_sub_case A string. Type of string case of `method_sub`, could
#'   be `raw` (no change), `lower`, `canonical`.
#' @return A ggplot2 object.
run_plot_prc <- function(
  dat_list, dec = 3, title = NULL,
  legend_xmin = 0.7, legend_ymin = 0.25, method_sub_case = "canonical") 
{
  func <- "run_plot_prc"

  p_data <- NULL
  for (dat in dat_list) {
    method_sub <- format_method_sub(dat$method_sub, method_sub_case)
    prc <- dat$prc
    d <- prc$df
    if (dec == 4)
      d$method <- sprintf("%s: AUC=%.4f", method_sub, prc$AUC)
    else
      d$method <- sprintf("%s: AUC=%.3f", method_sub, prc$AUC)
    p_data <- base::rbind(p_data, d)
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_line(
      data = p_data,
      ggplot2::aes(x = Recall, y = Precision, color = method, group = method),
      size = .3) +
    ggplot2::scale_x_continuous(breaks = c(0, .2, .4, .6, .8, 1)) +
    ggplot2::scale_y_continuous(breaks = c(0, .2, .4, .6, .8, 1)) +
    ggplot2::labs(
      x = "Recall", 
      y = "Precision", 
      title = title,
      color = NULL) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank()) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 7, hjust = .5, face = "bold"),
      axis.title = ggplot2::element_text(size = 6),
      axis.text = ggplot2::element_text(size = 4),
      axis.line = ggplot2::element_line(size = .3),
      axis.ticks = ggplot2::element_line(size = .3)) +
    ggplot2::theme(
      legend.key.size = ggplot2::unit(.5, "cm"),
      legend.key = ggplot2::element_rect(
        color = "transparent", fill = "transparent"),
      legend.key.height = ggplot2::unit(.25, "cm"),
      legend.position = c(legend_xmin, legend_ymin),
      legend.text = ggplot2::element_text(size = 5),
      legend.background = ggplot2::element_rect(
        color = "transparent", fill = "transparent"))

  return(p)
}


work_dir <- "supp_prc"
prefix <- "BCH869.loh.gene_scale"
dat_list <- readRDS("BCH869.loh.gene_scale.subset.data_list.list.rds")
truth_mtx <- readRDS("BCH869.loh.gene_scale.truth.cell_x_gene.binary.mtx.rds")
sid <- "BCH869"


# core part
setwd(work_dir)
source("benchmark.R")
source("utils.R")

func <- "main_prc"

flush_print(sprintf("[I::%s][%s] calculate PRC ...", func, str_now()))
dat_list <- run_prc(dat_list, truth_mtx, max_n_cutoff = 2000, strict = TRUE, 
                    verbose = TRUE) 
str(dat_list)

save_prc(dat_list, work_dir, prefix, save_all = TRUE)
flush_print(sprintf("[I::%s][%s] PRC data is saved to dir '%s'.", func,
            str_now(), work_dir))

flush_print(sprintf("[I::%s][%s] visualization ...", func, str_now()))
p_title <- sprintf("%s PRC Curve for LOH", sid)
p <- run_plot_prc(dat_list, dec = 3, title = p_title,
                  legend_xmin = 0.7, legend_ymin = 0.25)

plot_fn <- sprintf("%s/%s.plot.prc_figure.jpg", work_dir, prefix)
ggplot2::ggsave(plot_fn, p, width = 6.5, height = 5,
                units = "cm", dpi = 600)
flush_print(sprintf("[I::%s][%s] plot figure is saved to dir '%s'.", func,
            str_now(), work_dir))

print("All Done!")

