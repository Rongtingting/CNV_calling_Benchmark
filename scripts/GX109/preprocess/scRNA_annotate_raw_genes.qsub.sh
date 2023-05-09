#!/bin/bash
#PBS -N scRNA_annotate_raw_genes
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=100g,walltime=100:00:00
#PBS -o scRNA_annotate_raw_genes.out
#PBS -e scRNA_annotate_raw_genes.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/scRNA_annotate_raw_genes.R \
#  <input gene list>  \
#  <hg version>  \
#  <output anno file>

/usr/bin/time -v Rscript $work_dir/scRNA_annotate_raw_genes.R \
  $project_dir/input/GX109/scRNA/helen_filtered_matrices/genes.tsv \
  38  \
  $project_dir/output/GX109_preprocess/GX109.helen_filtered.matrix.genes.hg38.hgnc.rds

set +ux
conda deactivate
echo [`basename $0`] All Done!

