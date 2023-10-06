#!/bin/bash
# gen_eval.GBM_10x.run.sh


anno_dir=/groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/anno
repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
tool_dir=/groups/cgsd/xianjie/result/xclbm2/GBM/GBM_call_230825
gene_anno=/groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt
result_dir=/home/xianjie/debug/test-xclbm/normal


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate evaluation scripts for gene scale.\n"
out_dir=$result_dir/gene_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  GBM_10x   \
  --cnvScale  gene    \
  --outdir  $out_dir    \
  --xclone  $tool_dir/GBM_xclone/extracted_data    \
  --numbat  $tool_dir/GBM_numbat/result  \
  --casper  $tool_dir/GBM_casper/result  \
  --copykat  $tool_dir/GBM_copykat/result  \
  --infercnv  $tool_dir/GBM_infercnv/result  \
  --truth  $anno_dir/GBM_10xscrna.celltype.cnv.agg_cnvtype.sort.tsv  \
  --cellAnno  $anno_dir/GBM_10x.cell_anno.clone_mapping.for_cnv_truth.2column.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  3

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi


echo -e "\nGenerate evaluation scripts for arm scale.\n"
out_dir=$result_dir/arm_scale
python  $repo_scripts_dir/utils/gen_eval.py  \
  --sid  GBM_10x   \
  --cnvScale  arm    \
  --outdir  $out_dir    \
  --xclone  $tool_dir/GBM_xclone/extracted_data_merge_chr_arm  \
  --numbat  $tool_dir/GBM_numbat/result  \
  --casper  $tool_dir/GBM_casper/result  \
  --copykat  $tool_dir/GBM_copykat/result  \
  --infercnv  $tool_dir/GBM_infercnv/result  \
  --truth  $anno_dir/GBM_10xscrna.celltype.cnv.agg_cnvtype.sort.tsv  \
  --cellAnno  $anno_dir/GBM_10x.cell_anno.clone_mapping.for_cnv_truth.2column.tsv  \
  --geneAnno  $gene_anno    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  3

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

