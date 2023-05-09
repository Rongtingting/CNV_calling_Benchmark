
app <- "numbat.preprocess.allele.filter_ref.R"

args <- commandArgs(T)
if (length(args) < 6) {
  msg <- paste0("Usage: ", app, " <allele file> <ref cells file> \\
                                  <ref cell type>    \\
                                  <output dir> <out prefix> <save raw>")
  write(msg, file = stderr())
  quit("no", 1)
}

ale_fn <- args[1]
ref_cell_fn <- args[2]
ref_cell_type <- args[3]
out_dir <- args[4]
out_prefix <- args[5]
save_raw <- args[6]

library(dplyr)

ale <- read.delim(ale_fn, header = T, stringsAsFactors = F)
str(ale) 
if (save_raw == "True")
  saveRDS(ale, sprintf("%s/%s.raw.allele.dataframe.rds", out_dir, out_prefix))

ref_cells <- read.delim(ref_cell_fn, header = T, stringsAsFactors = F)
ale1 <- ale[! (ale$cell %in% ref_cells$cell), ]
str(ale1)
saveRDS(ale1, sprintf("%s/%s.%s_filtered.allele.dataframe.rds", out_dir, 
                          out_prefix, ref_cell_type))

print(paste0("[", app, "] All Done!"))

