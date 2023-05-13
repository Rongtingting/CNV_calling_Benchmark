# utils.R - Utils

flush_print <- function(s) {
  print(s)
  flush.console()
}


str_now <- function() {
  s <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  return(s)
}


write_tsv <- function(x, file_name) {
  write.table(x, file_name, sep = "\t", quote = FALSE, row.names = FALSE,
              col.names = TRUE)
}


#' Parse Region String
#' 
#' Parse a region string '[chr]xxx[:xxx-xxx]' to a vector of 
#' (chrom, start, end).
#' 
#' @param region A string representing a genomic region in the format of 
#'   '[chr]xxx[:xxx-xxx]'.
#' @return A string vector of 3 extracted elements: (chrom, start, end).
#'   Note that start and end would be -Inf or Inf if not specified in the 
#'   string.
#' @examples
#' parse_region1("chr1")         # c("chr1", "-Inf", "Inf")
#' parse_region1("22")           # c("22", "-Inf", "Inf")
#' parse_region1("chr22:-")      # c("chr22", "-Inf", "Inf")
#' parse_region1("chrX:1230")          # c("chrX", "1230", "Inf")
#' parse_region1("chrX:1230-")         # c("chrX", "1230", "Inf")
#' parse_region1("X:-20221230")        # c("X", "-Inf", "20221230")
#' parse_region1("X:1230-20221230")    # c("X", "1230", "20221230")
parse_region1 <- function(region) {
  chrom <- stringr::str_extract(region, "(.*?)(?=:|$)")

  start <- stringr::str_remove_all(
    stringr::str_extract(region, "(?<=:)(.*?)(?=-|$)"), ",")
  if (is.na(start) || is.na(as.numeric(start)))
    start <- -Inf

  end <- stringr::str_remove_all(
    stringr::str_extract(region, "(?<=-)(.*)"), ",")
  if (is.na(end) || is.na(as.numeric(end)))
    end <- Inf

  return(c(chrom = chrom, start = start, end = end))
}


#' Parse Multiple Regions
#' 
#' Parse a set of region strings into a dataframe of 3 columns.
#' 
#' @param regions A string vector of genomic regions, see `parse_region1`
#'   for details of the format of regions.
#' @return A data frame containing 3 columns: 1) chrom <chr>; 2) start <num>;
#'   3) end <num>. 
#' @examples
#' regions <- c("chr1", "22:1556", "chrX:1230-20221230")
#' parse_regions(regions)
parse_regions <- function(regions) {
  res <- sapply(regions, parse_region1)
  res <- as.data.frame(t(res))
  res$start <- as.numeric(res$start)
  res$end <- as.numeric(res$end)
  return(res)
}


#' Load XClone RDR Matrix
#' 
#' @param cell_fn A string. Path to file containing cell barcodes.
#' @param feature_fn A string. Path to file containing features.
#' @param mtx_fn A string. Path to file containing cell x gene data.
#' @return A cell x gene matrix.
load_mtx <- function(cell_fn, feature_fn, mtx_fn) {
  cells <- read.csv(cell_fn, header = F)
  features <- read.csv(feature_fn, header = T)
  mtx <- read.csv(mtx_fn, header = F)   # cell x gene matrix
  mtx <- as.matrix(mtx)
  rownames(mtx) <- cells$V1
  colnames(mtx) <- features$GeneName
  return(mtx)
}


#' Load XClone BAF Matrix
#' @inheritParams load_mtx
load_mtx2 <- function(cell_fn, feature_fn, mtx_fn) {
  cells <- read.csv(cell_fn, header = F)
  features <- read.csv(feature_fn, header = T)
  mtx <- read.csv(mtx_fn, header = F)   # cell x region matrix
  mtx <- as.matrix(mtx)
  rownames(mtx) <- cells$V1
  colnames(mtx) <- sprintf("%s:%s-%s", features$chr, features$start, 
                           features$stop)
  return(mtx)
}


#' Load XClone Matrix which is in Arm-Scale
#' @inheritParams load_mtx
load_mtx3 <- function(cell_fn, feature_fn, mtx_fn) {
  cells <- read.csv(cell_fn, header = F)
  features <- read.csv(feature_fn, header = T)
  mtx <- read.csv(mtx_fn, header = F)   # cell x gene matrix
  mtx <- as.matrix(mtx)
  rownames(mtx) <- cells$V1
  colnames(mtx) <- sprintf("%s:%s-%s", features$chr, features$start, 
                           features$stop)
  return(mtx)
}


#' Load Gene Annotation
#' 
#' Load gene annotation from a TSV file downloaded from XClone repo
#' whose first 5 columns are GeneName, GeneID, chr, start, stop.
#' 
#' @param gene_anno_fn A string. Path to the downloaded annotation file.
#' @return A dataframe containing 4 columns: 1) Gene <chr> gene name; 
#'   2) Chr <chr> chromosome; 3) start <int> 1-based start position of gene, 
#'   inclusive; 4) end <int> 1-based end position of gene, inclusive.
load_gene_anno <- function(gene_anno_fn) {
  gene_anno <- read.delim(gene_anno_fn, header = T, stringsAsFactors = F) %>%
    dplyr::select(GeneName, chr, start, stop) %>%
    dplyr::rename(Gene = GeneName, Chr = chr, end = stop) %>%
    dplyr::mutate(Chr = gsub("chr", "", Chr)) %>%
    dplyr::distinct(Gene, .keep_all = T)
  return(gene_anno)
}


#' Overlap Genes with Regions
#' @param regions A dataframe containing 4 columns: reg_id <str> Region ID,
#'   chrom <str>, start <int>, end <int>.
#' @param gene_anno A data frame. It should contain at least 4 columns:
#'   1) Gene <chr> gene name; 2) Chr <chr> chrom; 3) start <num> 
#'   1-based start pos, inclusive; 4) end <num> 1-based end pos, inclusive.
#' @return A list of 3 elements: 
#'   gene_overlap, a dataframe containing 2 columns: Gene, <str>, gene name;
#'     reg_id, <str> ID of overlapping region(s).
#'   n_dup, an integer, number of genes overlapping more than one region.
#'   gene_uniq, a dataframe containing 2 columns: Gene and reg_id, only for
#'     genes overlapping with one region.
overlap_gene_anno <- function(regions, gene_anno) {
  regions <- regions %>%
    dplyr::mutate(chrom = stringr::str_remove(chrom, "chr"))

  gene_anno <- gene_anno %>%
    dplyr::mutate(Chr = stringr::str_remove(Chr, "chr"))

  gene_overlap <- gene_anno %>%
    dplyr::group_by(Gene) %>%
    dplyr::group_modify(~{
      regions %>%
        dplyr::filter(chrom == .x$Chr[1]) %>%
        dplyr::filter(start <= .x$end[1] & end >= .x$start[1]) %>%
        dplyr::select(reg_id)
    }) %>%
    dplyr::ungroup()   # 2 columns: <Gene> <reg_id>

  gene_stat <- gene_overlap %>%
    dplyr::group_by(Gene) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup()   # 2 columns: <Gene> <n>

  gene_dup <- gene_stat %>%
    dplyr::filter(n > 1)

  gene_uniq <- gene_stat %>%
    dplyr::filter(n == 1) %>%
    dplyr::left_join(gene_overlap, by = "Gene")  %>%
    dplyr::select(Gene, reg_id)   # 2 columns: <Gene> <reg_id>

  return(list(
    gene_overlap = gene_overlap,
    n_dup = nrow(gene_dup),
    gene_uniq = gene_uniq
  ))
}


#' Convert cell x region Matrix to cell x gene Matrix
#' 
#' Convert cell x region matrix to cell x gene matrix by setting the values
#' of each gene to be the values of its unique overlapping region. If a gene
#' overlaps with more than one region, then the gene would be removed from
#' the returned matrix.
#' 
#' @inheritParams overlap_gene_anno
#' @param mtx A cell x region matrix. See `parse_region` for details of the
#'   format of regions.
#' @param verbose A bool. Whether to print detailed logging information.
#' @return A list containing 2 elements: 1) mtx, a cell x gene matrix
#'   containing only the genes overlapping with one region; 2) overlap, a
#'   data frame storing the overlapping results of all input genes, it contains
#'   2 columns: 2.1) Gene <string> gene name; 2.2) reg_id <string> region ID.
reg2gene <- function(mtx, gene_anno, verbose = TRUE) {
  func <- "reg2gene"

  regions <- parse_regions(colnames(mtx))
  regions <- cbind(colnames(mtx), regions)
  colnames(regions) <- c("reg_id", "chrom", "start", "end")
  regions$start <- as.numeric(regions$start)
  regions$end <- as.numeric(regions$end)

  res <- overlap_gene_anno(regions, gene_anno)
  gene_overlap <- res$gene_overlap
  n_dup <- res$n_dup
  gene_uniq <- res$gene_uniq

  if (verbose) {
    print(sprintf("[I::%s] gene_overlap:", func))
    str(gene_overlap)

    if (n_dup > 0) {
      print(sprintf("W::%s] there are %d genes overlap with >1 regions!", 
            func, n_dup))
    } 
    print(sprintf("[I::%s] %d genes overlap with 1 region.", 
                  func, nrow(gene_uniq)))
  }

  mtx_gene <- mtx[, gene_uniq$reg_id]
  colnames(mtx_gene) <- gene_uniq$Gene
  return(list(mtx = mtx_gene, overlap = gene_overlap))
}


#' Convert cell x var_region data frame to cell x gene Matrix
#' 
#' Convert cell x var_region data frame to cell x gene matrix by setting the 
#' values of each gene to be the values of its unique overlapping region. If 
#' a gene overlaps with more than one region, then the gene would be removed
#' from the returned matrix. Here, the var_region stands for variable regions 
#' between cells.
#' 
#' @param df A cell x region data frame. It should include at least 5 columns:
#'   1) cell <chr> cell barcodes; 2) chrom <chr>; 3) start <num> 1-based pos,
#'   inclusive; 4) end <num> 1-based pos, inclusive; 5) score <num> interested
#'   values, e.g., read counts.
#' @param gene_anno A data frame. It should contain at least 4 columns:
#'   1) Gene <chr> gene name; 2) Chr <chr> chrom; 3) start <num> 
#'   1-based start pos, inclusive; 4) end <num> 1-based end pos, inclusive.
#' @param verbose A bool. Whether to print detailed logging information.
#' @return A list containing 2 elements: 1) mtx, a cell x gene matrix
#'   containing only the genes overlapping with one region; 2) overlap, a
#'   data frame storing the overlapping results of all input genes, it contains
#'   4 columns: 2.1) Gene <string> gene name; 2.2) cell <chr> cell barcodes;
#'   2.3) reg_id <string> region ID; 2.4) score <num> interested values.
var_reg2gene <- function(df, gene_anno, verbose = TRUE) {
  func <- "var_reg2gene"

  df <- df %>%
    dplyr::mutate(reg_id = sprintf("%s:%s-%s", chrom, start, end))

  gene_overlap <- gene_anno %>%
    dplyr::group_by(Gene) %>%
    dplyr::group_modify(~{
      df %>%
        dplyr::filter(chrom == .x$Chr[1]) %>%
        dplyr::filter(start <= .x$end[1] & end >= .x$start[1]) %>%
        dplyr::select(cell, reg_id, score)
    }) %>%
    dplyr::ungroup()   # 4 columns: <Gene> <cell> <reg_id> <score>

  if (verbose) {
    print(sprintf("[I::%s] gene_overlap:", func))
    str(gene_overlap)
  }

  gene_stat <- gene_overlap %>%
    dplyr::group_by(Gene, cell) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup()   # 3 columns: <Gene> <cell> <n>

  gene_stat2 <- gene_stat %>%
    dplyr::filter(n == 1) %>%    # filter gene-cell overlapping >1 cnv regions.
    dplyr::group_by(Gene) %>%
    dplyr::summarise(m = dplyr::n()) %>%
    dplyr::ungroup()   # 2 columns: <Gene> <m>

  n_cell <- df %>%
    dplyr::distinct(cell) %>%
    nrow()

  gene_uniq <- gene_stat2 %>%
    dplyr::filter(m == n_cell) %>%     # filter genes missing in some cells.
    dplyr::left_join(gene_overlap, by = "Gene")  %>%
    dplyr::select(cell, Gene, score)

  mtx_gene <- gene_uniq %>%
    tidyr::spread(Gene, score)
  cells <- mtx_gene$cell
  mtx_gene <- as.matrix(mtx_gene[, -1])   # cell x gene matrix
  rownames(mtx_gene) <- cells

  return(list(mtx = mtx_gene, overlap = gene_overlap))
}
