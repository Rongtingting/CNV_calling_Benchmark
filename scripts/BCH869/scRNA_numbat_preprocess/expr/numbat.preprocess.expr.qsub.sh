#!/bin/bash
#PBS -N numbat_preprocess_expr
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=100g,walltime=100:00:00
#PBS -o numbat_preprocess_expr.out
#PBS -e numbat_preprocess_expr.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/numbat_preprocess_expr.R  \
#  <count matrix dir>  \
#  <ref cells file>   \
#  <ref cell type>  \
#  <out dir>    \
#  <out prefix>  \
#  <save raw> 

/usr/bin/time -v Rscript $work_dir/numbat.preprocess.expr.R  \
  $work_dir/../sim_matrix   \
  $work_dir/../BCH869.numbat.3.ref.cell.anno.tsv  \
  normal  \
  /groups/cgsd/xianjie/result/xclbm/res-v3/BCH869_numbat_preprocess/expr  \
  BCH869.numbat  \
  True

set +ux
conda deactivate
echo [`basename $0`] All Done!

