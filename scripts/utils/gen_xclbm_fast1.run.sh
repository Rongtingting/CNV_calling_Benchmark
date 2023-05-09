#!/bin/bash
# gen_xclbm_fast1.run.sh


anno_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA/anno
repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt
result_dir=/home/xianjie/debug/test-xclbm/fast1


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate xclbm scripts for gene scale.\n"
out_dir=$result_dir/gene_scale
python  $repo_scripts_dir/utils/gen_xclbm_fast1.py  \
  --sid  GX109   \
  --sp  GX109        \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/gene_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.sort.with_celltype.230508.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno     \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

chmod u+x $out_dir/run.sh


echo -e "\nGenerate xclbm scripts for arm scale.\n"
out_dir=$result_dir/arm_scale
python  $repo_scripts_dir/utils/gen_xclbm_fast1.py  \
  --sid  GX109   \
  --sp  GX109        \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --datList  /home/xianjie/debug/test-xclbm/normal/arm_scale  \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data_merge_chr_arm    \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.sort.with_celltype.230508.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno      \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

chmod u+x $out_dir/run.sh

