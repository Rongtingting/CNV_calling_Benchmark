#!/bin/bash
# gen_eval_fast2.GX109.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt
result_dir=/home/xianjie/debug/test-xclbm/fast2


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate evaluation scripts for gene scale.\n"
out_dir=$result_dir/gene_scale
python  $repo_scripts_dir/utils/gen_eval_fast2.py  \
  --sid  GX109   \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/gene_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data \
  --geneAnno  $gene_anno     \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi


echo -e "\nGenerate evaluation scripts for arm scale.\n"
out_dir=$result_dir/arm_scale
python  $repo_scripts_dir/utils/gen_eval_fast2.py  \
  --sid  GX109   \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/arm_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data_merge_chr_arm    \
  --geneAnno  $gene_anno      \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

