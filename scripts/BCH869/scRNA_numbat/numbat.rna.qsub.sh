#!/bin/bash
#PBS -N BCH_numbat
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=200g,walltime=100:00:00
#PBS -o BCH_numbat.out
#PBS -e BCH_numbat.err

source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/numbat.rna.R  \
#  <count matrix>  \
#  <ref expression>  \
#  <allele dataframe>  \
#  <out dir>   \
#  <out prefix>  \
#  <ncores>

/usr/bin/time -v Rscript $work_dir/numbat.rna.R  \
  $work_dir/expr/BCH869.numbat.normal_filtered.count.mtx.rds  \
  $work_dir/expr_ref/BCH869.numbat.ref.gene_by_celltype.mtx.rds  \
  $work_dir/allele_ref/BCH869.numbat.normal_filtered.allele.dataframe.rds  \
  $work_dir   \
  BCH869.numbat  \
  10

set +ux
conda deactivate
echo [`basename $0`] All Done!

