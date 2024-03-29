#!/bin/bash
# gen_eval.GX109.run.sh


anno_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA/anno
repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
tool_dir=/groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_0302
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt
result_dir=/home/xianjie/debug/test-xclbm/normal


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate evaluation scripts for gene scale.\n"
out_dir=$result_dir/gene_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  GX109   \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data \
  --numbat  $tool_dir/GX109_numbat  \
  --casper  $tool_dir/GX109_casper  \
  --copykat  $tool_dir/GX109_copykat  \
  --infercnv  $tool_dir/GX109_infercnv  \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.sort.with_celltype.231006.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi


echo -e "\nGenerate evaluation scripts for arm scale.\n"
out_dir=$result_dir/arm_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  GX109   \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --xclone  /groups/cgsd/xianjie/result/xclbm/GX109/GX109_5400_xclone_0403/extracted_data_merge_chr_arm    \
  --numbat  $tool_dir/GX109_numbat  \
  --casper  $tool_dir/GX109_casper  \
  --copykat  $tool_dir/GX109_copykat  \
  --infercnv  $tool_dir/GX109_infercnv  \
  --truth  $anno_dir/GX109.cnv.ground.truth_update.sort.with_celltype.231006.tsv  \
  --cellAnno  $anno_dir/GX109-T1c_scRNA_annotation_2column.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

