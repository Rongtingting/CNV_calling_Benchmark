
app <- "casper.rna.plot.R"

args <- commandArgs(T)
if (length(args) < 4) {
  msg <- paste0("Usage: ", app, " <sample id> <final chr mat> \\
                                  <loh median data> <out dir>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
final_chr_mat_fn <- args[2]
loh_median_fn <- args[3]
out_dir <- args[4]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
set.seed(123)

library(CaSpER)

final_chr_mat <- readRDS(final_chr_mat_fn)
loh_median <- readRDS(loh_median_fn)

#### VISUALIZATION 
## plot large scale events using event summary matrix 1: amplification, -1:deletion, 0: neutral
chr_mat <- final_chr_mat
plotLargeScaleEvent2(final_chr_mat, 
                     fileName=paste0(out_dir, "/", sid, ".large.scale.png"))

## plot BAF deviation for all samples together in one plot (can be used only with small sample size)
plotBAFAllSamples(loh=loh_median,
                  fileName=paste0(out_dir, "/", sid, ".LOH.all.samples.png")) 

plot.data <- melt(chr_mat)
plot.data$value2 <- "neutral"
plot.data$value2[plot.data$value > 0] <- "amplification"
plot.data$value2[plot.data$value < 0] <- "deletion"
plot.data$value2 <- factor(plot.data$value2, 
                           levels = c("amplification", "deletion", "neutral"))

p <- ggplot(aes(x = X2, y = X1, fill = value2), data = plot.data) + 
  geom_tile(colour = "white", size = 0.01) + 
  labs(x = "", y = "") + 
  scale_fill_manual(values = c(amplification = muted("red"), 
                               deletion = muted("blue"), neutral = "white")) + 
  theme_grey(base_size = 6) + 
  theme(legend.position = "right", legend.direction = "vertical", 
        legend.title = element_blank(), strip.text.x = element_blank(), 
        legend.text = element_text(colour = "black", size = 7, 
                                   face = "bold"), 
        legend.key.height = grid::unit(0.8,"cm"), 
        legend.key.width = grid::unit(0.5, "cm"), 
        axis.text.x = element_text(size = 5, colour = "black", 
                                   angle = -45, hjust = 0), 
        axis.text.y = element_text(size = 6, vjust = 0.2, colour = "black"), 
        axis.ticks = element_line(size = 0.4), 
        plot.title = element_text(colour = "black", 
                                  hjust = 0, 
                                  size = 6, face = "bold"))

jpeg(paste0(out_dir, "/", sid, ".baf.deviation.jpg"), height=8000, 
            width=4000, res=100)
p
dev.off()

print(paste0("[", app, "] All Done!"))

