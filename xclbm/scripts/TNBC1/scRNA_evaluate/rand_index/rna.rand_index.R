
app <- "rna.rand_index.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <sample id> <data dir> <data suffix> \\
                                  <all k> <truth> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
data_dir <- args[2]
data_suffix <- args[3]
all_k <- as.numeric(strsplit(args[4], ",")[[1]])
truth_fn <- args[5]
out_dir <- args[6]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(mclust)
library(stringr)

truth0 <- read.csv(truth_fn, row.names = 1, stringsAsFactors = F)
truth <- truth0$x
names(truth) <- rownames(truth0)

stat <- NULL
for (k in all_k) {
  kdir <- sprintf("%s/k%d", data_dir, k)
  if (! dir.exists(kdir)) {
    print(sprintf("Warning: no data dir for k = %d", k))
    next
  }
  objects <- list()
  objects[[1]] <- list(method = "truth", cluster = truth)
  i <- 2
  for (fn in dir(kdir, pattern = data_suffix)) {
    method <- strsplit(fn, ".", fixed = T)[[1]][2]
    print(sprintf("Begin to process '%s' with k = %d", method, k))
    fpath <- paste0(kdir, "/", fn)
    c1 <- readRDS(fpath)
    objects[[i]] <- list(method = method, cluster = c1)
    i <- i + 1
  }
  
  n <- length(objects)
  for (i in 1:(n - 1)) {
    obj_i <- objects[[i]]
    for (j in (i + 1):n) {
      obj_j <- objects[[j]]
      shared <- intersect(names(obj_i$cluster), names(obj_j$cluster))
      index <- adjustedRandIndex(obj_i$cluster[shared], obj_j$cluster[shared])
      stat <- rbind(stat, c(
        method1 = obj_i$method,
        method2 = obj_j$method,
        k = k,
        index = index,
        n1 = length(obj_i$cluster),
        n2 = length(obj_j$cluster),
        n_shared = length(shared)
      ))
    }
  }
}
  
stat <- as.data.frame(stat, stringsAsFactors = F)
#stat <- type.convert(stat)
write.table(stat, sprintf("%s.cluster.adjust.rand.index.tsv", sid),
            quote = F, sep = "\t", row.names = F)

print(paste0("[", app, "] All Done!"))

