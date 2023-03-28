
app <- "rna.extract.exp.R"

args <- commandArgs(T)
if (length(args) < 5) {
  msg <- paste0("Usage: ", app, " <sample id> <meta file> <truth cell> \\
                                  <truth gene> <out dir>")
  msg <- paste0(msg, "\n<meta file> has 3 columns per line: 'tool', 'in_dir', 'out_id'")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
meta_fn <- args[2]
truth_cell_fn <- args[3]
truth_gene_fn <- args[4]
out_dir <- args[5]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

truth_cell <- read.delim(truth_cell_fn, header = F, stringsAsFactors = F)
truth_cell <- truth_cell$V1
truth_gene <- read.delim(truth_gene_fn, header = F, stringsAsFactors = F)
truth_gene <- truth_gene$V1

objects <- list()
meta <- read.delim(meta_fn, header = T, stringsAsFactors = F)
for (i in 1:nrow(meta)) {
  tool <- meta$tool[i]
  in_dir <- meta$in_dir[i]
  out_id <- meta$out_id[i]
  expr <- NULL

  #copykat------------------------------------------------------------
  if (tool == "copykat") {
    expr_fn <- sprintf("%s/%s_copykat_CNA_raw_results_gene_by_cell.txt", in_dir, sid)
    expr <- read.delim(expr_fn, header = T, check.names = F, stringsAsFactors = F)
    rownames(expr) <- expr$hgnc_symbol
    expr <- expr[, -(1:7)]
    expr <- t(expr)    # cell x gene matrix
  }

  #casper--------------------------------------------------------------
  else if (tool == "casper") {
    obj_fn <- sprintf("%s/%s.object.rds", in_dir, sid)
    obj <- readRDS(obj_fn)
    expr <- log2(obj@control.normalized.noiseRemoved[[3]])
    expr <- t(expr)    # cell x gene matrix
  }

  #infercnv-------------------------------------------------------------
  else if (tool == "infercnv") {
    obj_fn <- sprintf("%s/BayesNetOutput.HMMi6.hmm_mode-samples/MCMC_inferCNV_obj.rds", in_dir)
    obj <- readRDS(obj_fn)
    expr <- obj@expr.data
    expr <- t(expr)    # cell x gene matrix
  }

  else {
    print(sprintf("[%s] Warning: unknown tool '%s'", app, tool))
    next
  }

  objects[[i]] <- list(
    id = out_id, 
    data = expr
  )
}

#consensus genes---------------------------------------------------------
i <- 1
for (obj in objects) {
  if (i == 1) {
    isec_gene <- colnames(obj$data)
  } else {
    isec_gene <- intersect(isec_gene, colnames(obj$data))
  }
  i <- i + 1
}
isec_gene <- sort(isec_gene)
write(isec_gene, paste0(sid, ".isec.gene.tsv"), sep = "\n")

#consensus cells----------------------------------------------------------
i <- 1
for (obj in objects) {
  if (i == 1) {
    isec_cell <- rownames(obj$data)
  } else {
    isec_cell <- intersect(isec_cell, rownames(obj$data))
  }
  i <- i + 1
}
isec_cell <- sort(isec_cell)
write(isec_cell, paste0(sid, ".isec.cell.barcodes.tsv"), sep = "\n")

#union genes---------------------------------------------------------------
i <- 1
for (obj in objects) {
  if (i == 1) {
    union_gene <- colnames(obj$data)
  } else {
    union_gene <- union(union_gene, colnames(obj$data))
  }
  i <- i + 1
}
union_gene <- sort(union_gene)
write(union_gene, paste0(sid, ".union.gene.tsv"), sep = "\n")

#union cells---------------------------------------------------------------
i <- 1
for (obj in objects) {
  if (i == 1) {
    union_cell <- rownames(obj$data)
  } else {
    union_cell <- union(union_cell, rownames(obj$data))
  }
  i <- i + 1
}
union_cell <- sort(union_cell)
write(union_cell, paste0(sid, ".union.cell.barcodes.tsv"), sep = "\n")

#final expr-----------------------------------------------------------------
for (obj in objects) {
  expr <- obj$data
  cells <- rownames(expr)
  if (! all(truth_cell %in% cells)) {
    print(sprintf("Warning: some truth cells are not in '%s'", obj$id))
    next
  }
  genes <- colnames(expr)
  if (! all(truth_gene %in% genes)) {
    print(sprintf("Warning: some truth genes are not in '%s'", obj$id))
    next
  }
  expr <- expr[truth_cell, truth_gene]
  saveRDS(expr, paste0(sid, ".isec.cell_x_gene.", obj$id, ".expr.rds"))
}

print(paste0("[", app, "] All Done!"))

