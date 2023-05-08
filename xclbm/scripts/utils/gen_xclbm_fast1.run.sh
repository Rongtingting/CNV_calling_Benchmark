#!/bin/bash
# gen_xclbm_fast1.run.sh


anno_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA/anno
repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/xclbm/scripts
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt
result_dir=/home/xianjie/debug/test-xclbm/fast1


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo "generate xclbm scripts for gene scale"
out_dir=$result_dir/gene_scale
python gen_xclbm_fast1.py  \
  --sid  GX109   \
  --sp  GX109        \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/gene_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data \
  --cnvCell  "stem, cancer cell"   \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno     \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

chmod u+x $out_dir/run.sh


echo "generate xclbm scripts for arm scale"
out_dir=$result_dir/arm_scale
python gen_xclbm_fast1.py  \
  --sid  GX109   \
  --sp  GX109        \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/arm_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data_merge_chr_arm    \
  --cnvCell  "stem, cancer cell"   \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno      \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

chmod u+x $out_dir/run.sh

