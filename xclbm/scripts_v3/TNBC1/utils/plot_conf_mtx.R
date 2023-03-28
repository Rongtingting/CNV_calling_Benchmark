# reference: https://stackoverflow.com/questions/37897252/plot-confusion-matrix-in-r-using-ggplot

library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

plot_conf_mtx <- function(in_fn, out_fig, method, fig_width = 8, fig_height = 6) {
  dat <- read.delim(in_fn, stringsAsFactors = F, check.names = F)
  #str(dat)
  dat <- dat %>%
    gather(label_tool, n, -label_truth)
  dstat <- dat %>%
    group_by(label_truth) %>%
    summarise(m = sum(n)) %>%
    ungroup()
  #str(dstat)
  dat <- dat %>%
    left_join(dstat, by = "label_truth") %>%
    mutate(freq = n / m) %>%
    mutate(fn_color = ifelse(freq > 0.5, "white", "black"))
  #str(dat)
  p <- ggplot(dat, aes(x = label_tool, y = label_truth, fill = freq)) +
    geom_tile() + 
    geom_text(aes(label = n, color = fn_color), size = 4) +
    scale_color_manual(values = c("white" = "white", "black" = "black")) +
    scale_fill_distiller(palette = "Blues", direction = 1) +
    labs(x = method, y = "Transcriptomes Clusters") +
    scale_x_discrete(labels = c("Clone A", "Clone B", "Normal")) +
    scale_y_discrete(limits = c("Normal", "Clone B", "Clone A")) +
    guides(color = "none") +
    guides(fill = guide_colourbar(title = NULL, barwidth = .5,
                                  barheight = 8)) +
    theme_bw() +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()) +
    theme(panel.background = element_blank()) +
    theme(panel.border = element_blank()) +
    theme(axis.ticks = element_blank()) +
    theme(axis.text.x = element_text(vjust = 4, size = 9)) +
    theme(axis.text.y = element_text(angle = 90, hjust = .5, vjust = -3, 
                                     size = 9))
  ggsave(out_fig, p, width = fig_width, height = fig_height, units = "cm",
         dpi = 600)
}

setwd("~/Desktop/xclbm_tmp/TNBC1_confusion_matrix/")

print("casper_n_hclust")
plot_conf_mtx(
  in_fn = "TNBC1.casper_n_hclust.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "casper_n_hclust.jpg", 
  method = "CaSpER"
)

print("casper_n_kmeans")
plot_conf_mtx(
  in_fn = "TNBC1.casper_n_kmeans.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "casper_n_kmeans.jpg", 
  method = "CaSpER_kmeans"
)

print("copykat_n_hclust")
plot_conf_mtx(
  in_fn = "TNBC1.copykat_n_hclust.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "copykat_n_hclust.jpg", 
  method = "CopyKAT"
)

print("copykat_null_hclust")
plot_conf_mtx(
  in_fn = "TNBC1.copykat_null_hclust.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "copykat_null_hclust.jpg", 
  method = "CopyKAT_null"
)

print("infercnv_n_comb")
plot_conf_mtx(
  in_fn = "TNBC1.infercnv_n_comb.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "infercnv_n_comb.jpg", 
  method = "InferCNV_n_comb"
)

print("infercnv_n_hclust")
plot_conf_mtx(
  in_fn = "TNBC1.infercnv_n_hclust.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "infercnv_n_hclust.jpg", 
  method = "InferCNV_n"
)

print("infercnv_null_comb")
plot_conf_mtx(
  in_fn = "TNBC1.infercnv_null_comb.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "infercnv_null_comb.jpg", 
  method = "InferCNV_null_comb"
)

print("infercnv_null_hclust")
plot_conf_mtx(
  in_fn = "TNBC1.infercnv_null_hclust.k3.confusion.matrix.with.label.by.sort_confusion.tsv",
  out_fig = "infercnv_null_hclust.jpg", 
  method = "InferCNV_null"
)

print("All Done!")
