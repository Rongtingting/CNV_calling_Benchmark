#!/bin/bash
#PBS -N numbat_preprocess_expr_ref
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=100g,walltime=100:00:00
#PBS -o numbat_preprocess_expr_ref.out
#PBS -e numbat_preprocess_expr_ref.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/numbat_preprocess_expr_ref.R  \
#  <count matrix dir>  \
#  <cell annotation>   \
#  <out file>

/usr/bin/time -v Rscript $work_dir/numbat.preprocess.expr_ref.R  \
  /groups/cgsd/xianjie/result/xclbm/data/GX109/scRNA/helen_filtered_matrices  \
  $work_dir/../allele_ref/GX109.ref.anno.immune.tsv  \
  $work_dir/GX109.numbat.immune.ref.gene_by_cell_type.mtx.rds

set +ux
conda deactivate
echo [`basename $0`] All Done!

