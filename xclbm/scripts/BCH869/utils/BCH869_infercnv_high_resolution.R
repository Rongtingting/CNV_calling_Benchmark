
library(infercnv)

data_dir <- "/groups/cgsd/xianjie/result/xclbm/res-v2/BCH869_infercnv_492_anno4clone"
out_dir <- "/groups/cgsd/xianjie/result/xclbm/res-v2-shared/BCH869_infercnv_high_resolution"

obj_set <- list(
  list(path = paste0(data_dir, "/", "BCH869_Normal/22_denoiseHMMi6.NF_NA.SD_1.5.NL_FALSE.infercnv_obj"),
       name = "BCH869_Normal")
)

for (obj1 in obj_set) {
  print(obj1$name)
  fn <- obj1$path
  infercnv_obj <- readRDS(fn)
  plot_cnv(
    infercnv_obj,
    out_dir=out_dir,
    obs_title="Observations (Cells)",
    ref_title="References (Cells)",
    cluster_by_groups=TRUE,
    x.center=1,
    x.range="auto",
    hclust_method='ward.D',
    color_safe_pal=FALSE,
    output_filename=obj1$name,
    output_format="png",
    png_res=600,
    dynamic_resize=0
  )
}

print("All Done!")

