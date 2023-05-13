# simulation.R - functions for simulations of cell downsampling.


simulate <- function(
  sid, mtx = NULL, gene_is_row = TRUE,
  cell_anno = NULL, target_cell_types = NULL,
  N = NULL, perc = NULL, seed = 123, sort_cells = TRUE,
  gene_anno = NULL,
  out_dir = NULL)
{
  func <- "simu_main_core"

  # sampling cells.
  sample_res <- simu_sample_cells(
    cell_anno = cell_anno, 
    target_cell_types = target_cell_types,
    N = N, perc = perc, 
    seed = seed, to_sort = sort_cells)

  print(sprintf("[I::%s] simulation sampling cells.", func))
  str(sample_res)

  res_dir <- sprintf("%s/barcodes", out_dir)
  safe_dir_create(res_dir)

  simu_save_sample(sample_res, res_dir)

  # subset count matrix.
  cell_anno <- sample_res[["cell_anno"]]
  subset_mtx_res <- simu_subset_matrix(
    mtx = mtx,
    subset_cells = sample_res[["sampled_cells"]],
    subset_genes = NULL,
    gene_is_row = gene_is_row
  )

  print(sprintf("[I::%s] simulation subsetting count matrix.", func))
  str(subset_mtx_res)

  subset_mtx <- subset_mtx_res

  res_dir <- sprintf("%s/matrix", out_dir)
  safe_dir_create(res_dir)

  simu_save_matrix(subset_mtx, gene_anno, res_dir, gene_is_row)
}


safe_dir_create <- function(dir_path, recursive = FALSE) {
  if (! dir.exists(dir_path))
    dir.create(dir_path, recursive = recursive)
}

#' @param mtx A matrix. Could be sparse matrix.
#' @param cell_anno A string vector.
#' @param gene_anno A string vector.
#' @param gene_is_row A bool. Whether to use genes as rownames.
#' @return Updated matrix with new row and column names.
load_10x_mtx <- function(mtx, cell_anno, gene_anno, gene_is_row = TRUE)
{
  if (gene_is_row) {
    rownames(mtx) <- gene_anno
    colnames(mtx) <- cell_anno
  } else {
    rownames(mtx) <- cell_anno
    colnames(mtx) <- gene_anno
  }
  return(mtx)
}

load_10x_mtx_wrapper <- function(mtx_fn, barcode_fn, gene_fn, gene_is_row = TRUE)
{
  mtx <- readMM(mtx_fn)
  barcodes_df <- read.delim(barcode_fn, header = FALSE, stringsAsFactors = FALSE)
  barcodes <- barcodes_df$V1
  genes_df <- read.table(gene_fn, header = FALSE, stringsAsFactors = FALSE)
  genes <- genes_df$V2
  mtx <- load_10x_mtx(mtx, barcodes, genes, gene_is_row)
  return(mtx)
}


#' @param cell_anno A dataframe containing at least 2 columns, <cell> and
#'   <cell_type>.
#' @param target_cell_types A vector of strings. Target cell types whose cells
#'   would be sampled.
#' @param N A integer. The number of cells to be sampled from
#'   `target_cell_types`.
#' @param perc A float. The fraction fo cells to be sampled from 
#'   `target_cell_types`.
#' @param seed A integer. Random seed.
#' @param to_sort A bool. Whether to sort the returned barcodes.
#' @return A list of four elements
#'   1. `sampled_target_cells` A string vector. sampled cell barcodes from 
#'      target cell types.
#'   2. `nonsampled_target_cells` A string vector. cells from target cell 
#'      types but not sampled.
#'   3. `sampled_cells` A string vector. sampled cell barcodes.
#'   4. `cell_anno` A dataframe. updated cell annotation with a new column 
#'      `sampled`, which indicates whether each cell is sampled (1) or not (0).
simu_sample_cells <- function(cell_anno, target_cell_types, N = NULL, perc = NULL, 
  seed = 123, to_sort = TRUE)
{
  func <- "simu_sample_cells"

  print(sprintf("[I::%s] cell_anno:", func))
  str(cell_anno)
  print(table(cell_anno$cell_type))
  
  target_cells <- cell_anno$cell[cell_anno$cell_type %in% target_cell_types]
  n_cells_target <- length(target_cells)

  n_cells_sampled <- -1

  if (! xor(is.null(N), is.null(perc)))
    stop(sprintf("[E::%s] one of N and perc should be NULL!", func))
  if (is.null(N)) {
    n_cells_sampled <- ceiling(n_cells_target * perc)
  } else {
    n_cells_sampled <- N
  }
  n_cells_sampled <- min(n_cells_sampled, n_cells_target)
  print(sprintf("[I::%s] #cells sampled is %d.", func, n_cells_sampled))

  set.seed(seed)
  sampled_target_cells <- sample(target_cells, n_cells_sampled)
  nonsampled_target_cells <- target_cells[! target_cells %in% sampled_target_cells]
  sampled_cells <- cell_anno$cell[! cell_anno$cell %in% nonsampled_target_cells]
  if (to_sort) {
    sampled_target_cells <- base::sort(sampled_target_cells)
    nonsampled_target_cells <- base::sort(nonsampled_target_cells)
    sampled_cells <- base::sort(sampled_cells)
  }

  cell_anno$sampled <- 1
  cell_anno$sampled[cell_anno$cell %in% nonsampled_target_cells] <- 0
  
  return(list(
    sampled_target_cells = sampled_target_cells,
    nonsampled_target_cells = nonsampled_target_cells,
    sampled_cells = sampled_cells,
    cell_anno = cell_anno
  )) 
}


simu_save_sample <- function(sample_res, out_dir)
{
  write(
    x = sample_res[["sampled_target_cells"]],
    file = sprintf("%s/sampled_target_cells.tsv", out_dir),
    sep = "\n"
  )

  write(
    x = sample_res[["nonsampled_target_cells"]],
    file = sprintf("%s/nonsampled_target_cells.tsv", out_dir),
    sep = "\n"
  )

  write(
    x = sample_res[["sampled_cells"]],
    file = sprintf("%s/sampled_cells.tsv", out_dir),
    sep = "\n"
  )

  write.table(
    x = sample_res[["cell_anno"]],
    file = sprintf("%s/updated_cell_annotation.tsv", out_dir),
    sep = "\t", quote = TRUE, row.names = FALSE, col.names = TRUE
  )

  cell_anno <- sample_res[["cell_anno"]]
  write.table(
    x = cell_anno[cell_anno$sampled == 1, c("cell", "cell_type")],
    file = sprintf("%s/sampled_cell_annotation_2column.tsv", out_dir),
    sep = "\t", quote = TRUE, row.names = FALSE, col.names = FALSE
  )
}


#' @param mtx A matrix. Could be sparse matrix.
#' @param subset_cells A string vector.
#' @param subset_genes A string vector.
#' @param gene_is_row A bool. Whether `mtx` uses genes as rownames.
#' @return subseted matrix.
simu_subset_matrix <- function(mtx, subset_cells = NULL, subset_genes = NULL,
  gene_is_row = TRUE) 
{
  if (! gene_is_row)
    mtx <- t(mtx)

  if (! is.null(subset_genes))
    mtx <- mtx[subset_genes, ]
  if (! is.null(subset_cells))
    mtx <- mtx[, subset_cells]
  
  if (! gene_is_row)
    mtx <- t(mtx)

  return(mtx)
}


#' @param mtx A matrix. Could be sparse matrix.
#' @param gene_anno A dataframe containing at least two columns <gene_id>
#'   <gene_name>.
#' @param out_dir A string. Output dir.
#' @param gene_is_row A bool. Whether `mtx` uses genes as rownames.
#' @return A list of three elements
#'   1. `cell_fn` A string. the filename of cell barcodes.
#'   2. `gene_fn` A string. the filename of genes. 
#'   3. `mtx_fn` A string. the filename of sparse matrix.
simu_save_matrix <- function(mtx, gene_anno, out_dir, gene_is_row = TRUE)
{
  func <- "simu_save_matrix"

  cell_fn <- sprintf("%s/barcodes.tsv", out_dir)
  gene_fn <- sprintf("%s/genes.tsv", out_dir)
  mtx_fn <- sprintf("%s/matrix.mtx", out_dir)

  if (! gene_is_row)
    mtx <- t(mtx)
  genes <- rownames(mtx)
  cells <- colnames(mtx)

  # output cells
  write(cells, cell_fn, sep = "\n")

  # output genes
  gene_id = gene_anno$gene_id[gene_anno$gene_name %in% genes]
  n_gene_id <- length(gene_id)
  n_gene_name <- length(genes)
  if (n_gene_id != n_gene_name)
    stop(sprintf("[E::%s] #gene_name (%d) != #gene_id (%d).", func,
          n_gene_name, n_gene_id))
  gene_df <- data.frame(
    gene_id = gene_id,
    gene_name = genes,
    stringsAsFactors = FALSE
  )
  write.table(gene_df, gene_fn, sep = " ", quote = FALSE,
              row.names = FALSE, col.names = FALSE)

  # output matrix
  Matrix::writeMM(mtx, mtx_fn)

  return(list(
    cell_fn = cell_fn,
    gene_fn = gene_fn,
    mtx_fn = mtx_fn
  ))
}


