
app <- "scDNA_extract_ground_truth.R"

args <- commandArgs(T)
if (length(args) < 7) {
  msg <- paste0("Usage: ", app, " <sample id> <cnv file> <target node> \\
                                  <gain regions> <loss regions> \\
                                  <out dir> <utils>")
  write(msg, file = stderr())
  quit("no", 1)
}

sid <- args[1]
cnv_fn <- args[2]
target_node <- as.numeric(args[3])
in_gain_raw <- strsplit(args[4], ",")[[1]]
in_loss_raw <- strsplit(args[5], ",")[[1]]
out_dir <- args[6]
utils_fn <- args[7]

if (! dir.exists(out_dir)) {
  dir.create(out_dir, recursive = T)
}

setwd(out_dir)
source(utils_fn)

all_region_fn <- sprintf("%s.scDNA.cellranger.node%d.all.region.tsv", 
                          sid, target_node)
gain_region_fn <- sprintf("%s.scDNA.cellranger.node%d.copy.gain.region.tsv", 
                          sid, target_node)
loss_region_fn <- sprintf("%s.scDNA.cellranger.node%d.copy.loss.region.tsv", 
                          sid, target_node)

library(dplyr)
library(tidyr)
library(stringr)

cnv0 <- read.csv(cnv_fn, header = T, stringsAsFactors = F, check.names = F) %>%
  as_tibble()

cnv <- cnv0 %>% 
  select(-barcodes, -num_cells, -num_noisy) %>%
  filter(node_id == target_node) %>%
  gather(region, copy_number, -node_id) %>%
  mutate(chrom = str_extract(region, "(.*)(?=:)")) %>%
  mutate(start = as.numeric(
    str_remove_all(
      str_extract(region, "(?<=:)(.*)(?=-)"), ","
    )
  )) %>%
  mutate(end = as.numeric(
    str_remove_all(
      str_extract(region, "(?<=-)(.*)"), ","
    )
  ))
write.table(cnv, all_region_fn, quote = F, sep = "\t", row.names = F,
            col.names = T)

in_gain <- parse_regions(in_gain_raw)
in_loss <- parse_regions(in_loss_raw)

gain <- cnv %>%
  filter(copy_number > 2.3) %>%
  group_by(region) %>%
  group_modify(~{
    in_gain %>%
      mutate(in_reg_id = sprintf("%s:%s-%s", chrom, start, end)) %>%
      filter(chrom == .x$chrom[1]) %>%
      filter(start <= .x$end[1] & end >= .x$start[1]) %>%
      select(in_reg_id)
  }) %>%
  ungroup()
gain <- gain %>%
  left_join(cnv, by = "region") %>%  
  select(chrom, start, end, copy_number, in_reg_id)
write.table(gain, gain_region_fn, quote = F, sep = "\t", row.names = F,
            col.names = T)

loss <- cnv %>%
  filter(copy_number < 1.7) %>%
  group_by(region) %>%
  group_modify(~{
    in_loss %>%
      mutate(in_reg_id = sprintf("%s:%s-%s", chrom, start, end)) %>%
      filter(chrom == .x$chrom[1]) %>%
      filter(start <= .x$end[1] & end >= .x$start[1]) %>%
      select(in_reg_id)
  }) %>%
  ungroup()
loss <- loss %>%
  left_join(cnv, by = "region") %>%
  select(chrom, start, end, copy_number, in_reg_id)
write.table(loss, loss_region_fn, quote = F, sep = "\t", row.names = F,
            col.names = T)

print(paste0("[", app, "] All Done!"))

