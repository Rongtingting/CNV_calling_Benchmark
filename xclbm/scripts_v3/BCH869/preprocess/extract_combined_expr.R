
app <- "extract_combined_expr.R"

args <- commandArgs(T)
if (length(args) < 3) {
  msg <- paste0("Usage: ", app, " <input expr> <cell id> \\
                                  <output expr>")
  write(msg, file = stderr())
  quit("no", 1)
}

in_fn <- args[1]
cell_fn <- args[2]
out_fn <- args[3]

expr0 <- read.csv(in_fn, row.names = 1, stringsAsFactors = F) # gene x cell
cells <- read.table(cell_fn, header = F, stringsAsFactors = F)
expr <- expr0[, colnames(expr0) %in% cells$V1]
write.csv(expr, out_fn)

print(paste0("[", app, "] All Done!"))

