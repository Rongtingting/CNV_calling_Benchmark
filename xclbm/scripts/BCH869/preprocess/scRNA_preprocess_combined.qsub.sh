#!/bin/bash
#PBS -N bch869-pre-combined
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch869_pre_combined.out
#PBS -e bch869_pre_combined.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

if [ ! -d "$project_dir/output/BCH869_preprocess" ]; then
  mkdir -p $project_dir/output/BCH869_preprocess
fi

# extract gene list
gene_lst=$project_dir/output/BCH869_preprocess/BCH869.combined.genes.raw.tsv
cat $project_dir/input/BCH869/scRNA/BCH869.combined.expr.csv | \
  awk -F',' 'NR > 1 {print $1}' | \
  sed 's/"//g' > $gene_lst

gene_uniq_lst=$project_dir/output/BCH869_preprocess/BCH869.combined.genes.sort.uniq.tsv
cat $gene_lst | sort | uniq > $gene_uniq_lst

# annotate genes
#Rscript $work_dir/scRNA_annotate_raw_genes.R \
#  <input gene list>  \
#  <hg version>  \
#  <output anno file>

/usr/bin/time -v Rscript $work_dir/scRNA_annotate_raw_genes.R \
  $gene_uniq_lst  \
  19  \
  $project_dir/output/BCH869_preprocess/BCH869.combined.expr.genes.hgnc.hg19.rds

# extract expr matrix for the 492 cells
#Rscript $work_dir/extract_combined_expr.R \
#  <input combined file>  \
#  <target cells>   \
#  <out file>

Rscript $work_dir/extract_combined_expr.R \
  $project_dir/input/BCH869/scRNA/BCH869.combined.expr.csv \
  $project_dir/input/BCH869/scRNA/BCH869.492.cell.id.tsv  \
  $project_dir/output/BCH869_preprocess/BCH869.492.expr.csv

set +ux
conda deactivate
echo [`basename $0`] All Done!

