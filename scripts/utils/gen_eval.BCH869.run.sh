#!/bin/bash
# gen_eval.BCH869.run.sh


anno_dir=/groups/cgsd/xianjie/data/dataset/BCH869/anno
repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
tool_dir=/groups/cgsd/xianjie/result/xclbm/BCH869/BCH869_call_230307
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg19_update.txt
result_dir=/home/xianjie/debug/test-xclbm/evaluation/BCH869/normal


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate evaluation scripts for gene scale.\n"
out_dir=$result_dir/gene_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  BCH869  \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --xclone  $tool_dir/BCH869_xclone_230403/extracted_data  \
  --numbat  $tool_dir/BCH869_numbat_v1.2.1  \
  --casper  $tool_dir/BCH869_casper  \
  --copykat  $tool_dir/BCH869_copykat  \
  --infercnv  $tool_dir/BCH869_infercnv  \
  --truth  $anno_dir/BCH869.cnv.ground.truth.clean.0316.tsv  \
  --cellAnno  $anno_dir/BCH869.492.cell.clone.anno.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  3

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi


echo -e "\nGenerate evaluation scripts for arm scale.\n"
out_dir=$result_dir/arm_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  BCH869   \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --xclone  $tool_dir/BCH869_xclone_230403/extracted_data_merge_chr_arm    \
  --numbat  $tool_dir/BCH869_numbat_v1.2.1  \
  --casper  $tool_dir/BCH869_casper  \
  --copykat  $tool_dir/BCH869_copykat  \
  --infercnv  $tool_dir/BCH869_infercnv  \
  --truth  $anno_dir/BCH869.cnv.ground.truth.clean.0316.tsv  \
  --cellAnno  $anno_dir/BCH869.492.cell.clone.anno.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  3

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

