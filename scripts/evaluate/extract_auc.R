

library(dplyr)

get_table1 <- function(cnv_scale, cnv_type, metric, fn) {
  dat <- read.table(fn, header = TRUE, sep = "\t",
                    stringsAsFactors = FALSE)
  colnames(dat)[ncol(dat)] <- paste0(cnv_type, "_", colnames(dat)[ncol(dat)])
  return(dat)
}


get_table2 <- function(cnv_scale, metric, dir_path) {
  metric_dir_id <- NULL
  if (metric == "roc")
    metric_dir_id <- "s5_roc"
  else
    metric_dir_id <- "s6_prc"

  all_dat <- NULL
  i <- 1
  for (cnv_type in c("copy_gain", "copy_loss", "loh")) {
    cnv_type_dir <- sprintf("%s/%s/result/%s", dir_path, cnv_type,
                            metric_dir_id)
    if (! dir.exists(cnv_type_dir)) {
      cnv_type_dir <- sprintf("%s/%s/%s", dir_path, cnv_type,
                              metric_dir_id)
      if (! dir.exists(cnv_type_dir))
        stop(sprintf("dir '%s' does not exist!", cnv_type_dir))
    }
    
    fn_list <- list.files(cnv_type_dir, pattern = ".auc.df.tsv")
    fn <- sprintf("%s/%s", cnv_type_dir, fn_list[1])
    
    dat <- get_table1(cnv_scale = cnv_scale,
                      cnv_type = cnv_type,
                      metric = metric,
                      fn = fn)

    if (cnv_type == "loh") {
      casper_rows <- dat %>% filter(method == "casper")
      if (nrow(casper_rows) > 1) {
        min_val <- min(casper_rows[, ncol(casper_rows)])
        for (i in 1:nrow(dat)) {
          if (dat$method[i] == "casper" && dat[i, ncol(dat)] == min_val)
            break
        }
        dat <- dat[-i, ]
      }
    }
    
    if (i == 1)
      all_dat <- dat
    else {
      dat <- dat[, c(1, ncol(dat)]
      all_dat <- all_dat %>%
        left_join(dat, by = "method")
    }
    i <- i + 1
  }
  
  return(all_dat)
}


get_table3 <- function(cnv_scale, dir_path) {
  all_dat <- NULL
  roc_dat <- get_table2(cnv_scale = cnv_scale,
                        metric = "roc",
                        dir_path = dir_path)
  prc_dat <- get_table2(cnv_scale = cnv_scale,
                        metric = "prc",
                        dir_path = dir_path)
  all_dat <- cbind(roc_dat, prc_dat[ncol(prc_dat)-2:ncol(prc_dat)])
  return(all_dat)
}


