
app <- "rna.cluster.R"

args <- commandArgs(T)
if (length(args) < 4) {
  msg <- paste0("Usage: ", app, " <sample id> <meta file> <k> <out dir>")
  msg <- paste0(msg, "\n<meta file> has 3 columns per line: 'tool', 'in_dir', 'out_id'")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
meta_fn <- args[2]
all_k <- as.numeric(strsplit(args[3], ",")[[1]])
out_dir <- args[4]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

for (k in all_k) {
  res_dir <- paste0("k", k)
  if (! dir.exists(res_dir)) {
    dir.create(res_dir, recursive = T)
  }
}

meta <- read.delim(meta_fn, header = T, stringsAsFactors = F)
for (i in 1:nrow(meta)) {
  tool <- meta$tool[i]
  in_dir <- meta$in_dir[i]
  out_id <- meta$out_id[i]
  print(sprintf("Begin to process '%s'...", out_id))

  #copykat---------------------------------------------------------------------
  if (tool == "copykat") {
    obj_fn <- sprintf("%s/%s.copykat.obj.init.rds", in_dir, sid)
    obj <- readRDS(obj_fn)
    c0 <- obj$hclustering
    saveRDS(c0, sprintf("%s.%s_hclust.cluster.rds", sid, out_id))

    for (k in all_k) {
      c1 <- cutree(tree = c0, k = k)
      saveRDS(c1, sprintf("k%d/%s.%s_hclust.cluster.k%d.rds", k, sid, out_id, k))
    }
  }

  #casper---------------------------------------------------------------------
  else if (tool == "casper") {
    obj_fn <- sprintf("%s/%s.object.rds", in_dir, sid)
    obj <- readRDS(obj_fn)
    expr <- log2(obj@control.normalized.noiseRemoved[[3]])

    c0 <- hclust(dist(t(expr)))
    saveRDS(c0, sprintf("%s.%s_hclust.cluster.rds", sid, out_id))
    for (k in all_k) {
      c1 <- cutree(tree = c0, k = k)
      saveRDS(c1, sprintf("k%d/%s.%s_hclust.cluster.k%d.rds", k, sid, out_id, k))
      c2 <- kmeans(t(expr), centers = k, iter.max = 20, nstart = 2)
      saveRDS(c2$cluster, sprintf("k%d/%s.%s_kmeans.cluster.k%d.rds", 
                                  k, sid, out_id, k))
    }
  }

  #infercnv------------------------------------------------------------------
  else if (tool == "infercnv") {
    obj_fn <- sprintf("%s/BayesNetOutput.HMMi6.hmm_mode-samples/MCMC_inferCNV_obj.rds", in_dir)
    obj <- readRDS(obj_fn)
    expr <- obj@expr.data

    c0 <- hclust(dist(t(expr)))
    saveRDS(c0, sprintf("%s.%s_hclust.cluster.rds", sid, out_id))
    c_n <- obj@tumor_subclusters$hc$diploid      # update the cluster names!
    c_t <- obj@tumor_subclusters$hc$aneuploid
    for (k in all_k) {
      c1 <- cutree(tree = c0, k = k)
      saveRDS(c1, sprintf("k%d/%s.%s_hclust.cluster.k%d.rds", k, sid, out_id, k))
      c_n2 <- cutree(tree = c_n, k = 1)
      c_t2 <- cutree(tree = c_t, k = k - 1)
      c_t2 <- c_t2 + 1    # as the index of normal cluster is 1
      c2 <- c(c_n2, c_t2)
      saveRDS(c2, sprintf("k%d/%s.%s_comb.cluster.k%d.rds", k, sid, out_id, k))
    }
  }

  else {
    print(sprintf("[%s] Warning: unknown tool '%s'", app, tool))
    next
  }
}

print(paste0("[", app, "] All Done!"))

