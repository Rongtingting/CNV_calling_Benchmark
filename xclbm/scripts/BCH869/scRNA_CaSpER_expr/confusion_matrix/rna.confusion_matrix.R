
app <- "rna.confusion_matrix.R"

args <- commandArgs(T)
if (length(args) < 7) {
  msg <- paste0("Usage: ", app, " <data dir> <data suffix> \\
                                  <tool cluster labels> <truth file> \\
                                  <truth cluster labels> <out dir> \\
                                  <out prefix>") 
  write(msg, file = stderr())
  quit("no", 1)
}

data_dir <- args[1]
data_suffix <- args[2]
tool_labels <- strsplit(args[3], ",")[[1]]
truth_fn <- args[4]
truth_labels <- strsplit(args[5], ",")[[1]]
out_dir <- args[6]
out_prefix <- args[7]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

set.seed(123)

library(dplyr)
library(tidyr)
library(combinat)

truth <- read.csv(truth_fn, row.names = 1, stringsAsFactors = F)
truth <- truth %>%
  rename(x = clone_ID_paper) %>%
  mutate(cell = rownames(truth)) %>%
  select(cell, x)

k_truth <- length(unique(truth$x))

if (length(truth_labels) != k_truth) {
  stop(sprintf("length of truth labels and truth IDs are not the same"))
}

#strategies <- c("sort_raw", "sort_confusion")
strategies <- c("sort_confusion")
for (fn in dir(data_dir, pattern = data_suffix)) {
  tool_fn <- paste0(data_dir, "/", fn)
  method <- strsplit(fn, ".", fixed = T)[[1]][2]
  res_dir <- paste0(out_dir, "/", method)
  res_prefix <- sprintf("%s.%s", out_prefix, method)
  print(sprintf("Begin to process '%s'", res_prefix))

  if (! dir.exists(res_dir)) {
    dir.create(res_dir, recursive = T)
  }
  setwd(res_dir)

  tool <- readRDS(tool_fn)
  tool <- data.frame(x = tool) %>%
    mutate(cell = names(tool))

  k_tool <- length(unique(tool$x))

  if (length(tool_labels) != k_tool) {
    stop(sprintf("'%s' length of tool labels and tool IDs are not the same", 
                 res_prefix))
  }

  # merge truth and tool vectors
  merged <- truth %>%
    full_join(tool, by = "cell", suffix = c("_truth", "_tool")) %>%
    select(cell, x_truth, x_tool)
  write.table(merged, sprintf("%s.tool.truth.merged.tsv", res_prefix),
              quote = F, sep = "\t", row.names = F)

  if (nrow(merged) != nrow(truth)) {
    print(sprintf("Warning: '%s' cells in truth and tool files are not the same",
                  res_prefix))
  } else {
    print(sprintf("Info: '%s' cells in truth and tool files are the same",
                  res_prefix))
  }
  
  # generate confusion matrix with shared cells between truth and tool.
  all_combinations <- expand.grid(
    x_truth = 1:k_truth,
    x_tool = 1:k_tool
  )
  
  # shared has 3 columns: <x_truth> <x_tool> <n>
  shared <- truth %>%
    inner_join(tool, by = "cell", suffix = c("_truth", "_tool")) %>%
    group_by(x_truth, x_tool) %>%
    summarise(n = n()) %>%
    ungroup() %>%
    right_join(all_combinations, by = c("x_truth", "x_tool")) %>%
    mutate(n = ifelse(is.na(n), 0, n))

  shared0 <- shared %>%
    spread(x_tool, n)

  write.table(shared0, sprintf("%s.confusion.matrix.with.id.tsv", res_prefix),
              quote = F, sep = "\t", row.names = F)
    
  # map cluster id and cluster label with 2 strategies:
  k_max <- max(k_truth, k_tool)
  id_label <- data.frame(  # connect `truth cluster id` to `truth cluster label` and `tool cluster label`
    x_truth = c(1:k_truth, rep(NA, k_max - k_truth)),
    label_truth = c(truth_labels, rep(NA, k_max - k_truth)),
    label_tool = c(tool_labels, rep(NA, k_max - k_tool)),
    stringsAsFactors = F
  )
  
  # for each strategy, we should calculate a data.frame object
  # `stat` containing 2 columns `x_truth` and `x_tool`
  df_k <- data.frame(x = 1:k_max)
  for (strategy in strategies) {
    # Strategy-1: sort raw cell counts
    #   we map the cluster to label based on the assumption that the truth 
    #   cluster should be in the same position in the truth vectors and 
    #   the tool vectors after sorting by cell counts
    if (strategy == "sort_raw") {
      truth_stat <- truth %>%
        group_by(x) %>%
        summarise(n = n()) %>%
        ungroup() %>%
        right_join(df_k, by = "x") %>%
        arrange(n)
  
      tool_stat <- tool %>%
        group_by(x) %>%
        summarise(n = n()) %>%
        ungroup() %>%
        right_join(df_k, by = "x") %>%
        arrange(n)
  
      stat <- data.frame(      # map `truth cluster id` to `tool cluster id`
        x_truth = truth_stat$x,
        x_tool = tool_stat$x,
        n_truth = truth_stat$n,
        n_tool = tool_stat$n,
        stringsAsFactors = F
      )
    }

    # Strategy-2: select certain permutation of `tool cluster id` whose 
    # sum of diagonal counts of the confusion matrix is largest
    else if (strategy == "sort_confusion") {
      mtx <- as.matrix(shared0[, -1])
      rownames(mtx) <- shared0$x_truth  # here, the row/col names are "1","2",...

      all_permutations <- permn(1:k_tool)
      max_sum <- -1
      max_sum_clusters <- NULL
      for (i in 1:length(all_permutations)) {
        tool_clusters <- all_permutations[[i]]
        mtx <- mtx[, as.character(tool_clusters)]
        diag_sum <- sum(diag(mtx))
        if (diag_sum > max_sum) {
          max_sum <- diag_sum
          max_sum_clusters <- tool_clusters
        }
      }
      print(sprintf("'%s' max_diag_sum = %d", res_prefix, max_sum))

      stat <- data.frame(
        x_truth = c(as.numeric(rownames(mtx)), rep(NA, k_max - k_truth)),
        x_tool = c(max_sum_clusters, rep(NA, k_max - k_tool)),
        stringsAsFactors = F
      )
    }

    else { stat <- NULL }

    id_label2 <- id_label %>%   # map `tool cluster id` to `tool cluster label`
      left_join(stat, by = "x_truth")
  
    write.table(id_label2, 
                sprintf("%s.id_label.mapping.by.%s.tsv", res_prefix, strategy),
                quote = F, sep = "\t", row.names = F)
  
    shared2 <- shared %>%
      left_join(id_label2 %>% select(x_truth, label_truth), by = "x_truth") %>%
      left_join(id_label2 %>% select(x_tool, label_tool), by = "x_tool") %>%
      select(label_truth, label_tool, n) %>%
      spread(label_tool, n)

    write.table(
      shared2, 
      sprintf("%s.confusion.matrix.with.label.by.%s.tsv", res_prefix, strategy),
      quote = F, sep = "\t", row.names = F
    )
  }
}
  
print(paste0("[", app, "] All Done!"))

