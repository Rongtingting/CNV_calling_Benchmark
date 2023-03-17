#!/bin/bash
#PBS -N numbat_unclassified_filter
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=200g,walltime=100:00:00
#PBS -o numbat_unclassified_filter.out
#PBS -e numbat_unclassified_filter.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclbm/CNV_calling_Benchmark/v2

#Rscript $work_dir/numbat.rna.R  \
#  <count matrix>  \
#  <ref expression>  \
#  <allele dataframe>  \
#  <out dir>   \
#  <out prefix>  \
#  <ncores>

/usr/bin/time -v Rscript $work_dir/numbat.rna.R  \
  $project_dir/output/GX109_numbat_preprocess/expr/GX109.numbat.unclassified_filtered.count.mtx.rds  \
  $project_dir/output/GX109_numbat_preprocess/expr_ref/GX109.numbat.unclassified.ref.gene_by_cell_type.mtx.rds  \
  $project_dir/output/GX109_numbat_preprocess/allele/filter_ref/GX109.numbat.unclassified_filtered.allele.dataframe.rds  \
  $work_dir     \
  GX109.numbat.unclassified.filter  \
  10

set +ux
conda deactivate
echo [`basename $0`] All Done!

