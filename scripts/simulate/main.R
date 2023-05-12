# main.R - main functions for simulations of cell downsampling.


#' @param cell_anno_fn A tsv file (without header) containing 2 columns:
#'   <cell> <cell_type>.
#' @param gene_anno_fn A txt file (without header; separated by space) containing
#'   2 columns: <gene_id> <gene_name>. typically the `genes.tsv` in 10x count dir.
simu_main <- function(
  sid, dir_10x = NULL, gene_is_row = TRUE,
  cell_anno_fn = NULL, target_cell_types = NULL,
  N = NULL, perc = NULL, seed = 123, sort_cells = TRUE,
  gene_anno_fn = NULL,
  out_dir = NULL)
{
  func <- "simu_main"
 
  # load 10x count matrix
  mtx <- load_10x_mtx_wrapper(
    mtx_fn = sprintf("%s/matrix.mtx", dir_10x),
    barcode_fn = sprintf("%s/barcodes.tsv", dir_10x),
    gene_fn = sprintf("%s/genes.tsv", dir_10x),
    gene_is_row = gene_is_row
  )

  print(sprintf("[I::%s] load 10x count matrix.", func))
  str(mtx)

  # load cell annotation
  cell_anno <- read.delim(cell_anno_fn, header = FALSE, stringsAsFactors = FALSE)
  colnames(cell_anno) <- c("cell", "cell_type")
  
  print(sprintf("[I::%s] load cell annotation.", func))
  str(cell_anno)

  # load gene annotation
  gene_anno <- read.table(gene_anno_fn, header = FALSE, stringsAsFactors = FALSE)
  colnames(gene_anno) <- c("gene_id", "gene_name")

  print(sprintf("[I::%s] load gene annotation.", func))
  str(gene_anno)

  # core part
  simulate(
    sid = sid, 
    mtx = mtx, gene_is_row = gene_is_row,
    cell_anno = cell_anno, target_cell_types = target_cell_types,
    N = N, perc = perc, seed = seed, sort_cells = sort_cells,
    gene_anno = gene_anno,
    out_dir = out_dir
  )
}


