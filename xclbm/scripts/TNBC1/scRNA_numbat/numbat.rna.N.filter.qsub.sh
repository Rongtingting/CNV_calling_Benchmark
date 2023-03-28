#!/bin/bash
#PBS -N numbat_N_filter
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=200g,walltime=100:00:00
#PBS -o numbat_N_filter.out
#PBS -e numbat_N_filter.err

source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=/groups/cgsd/xianjie/result/xclbm/v3/run/TNBC1/result/TNBC1_numbat_preprocess_0224

#Rscript $work_dir/numbat.rna.R  \
#  <count matrix>  \
#  <ref expression>  \
#  <allele dataframe>  \
#  <out dir>   \
#  <out prefix>  \
#  <ncores>

/usr/bin/time -v Rscript $work_dir/numbat.rna.R  \
  $project_dir/expr/TNBC1.numbat.N_filtered.count.mtx.rds  \
  $project_dir/expr_ref/TNBC1.numbat.N.ref.gene_by_cell_type.mtx.rds  \
  $project_dir/allele_ref/TNBC1.numbat.N_filtered.allele.dataframe.rds  \
  $work_dir     \
  TNBC1.numbat.N.filter  \
  10

set +ux
conda deactivate
echo [`basename $0`] All Done!

