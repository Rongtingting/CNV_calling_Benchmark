#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N gx109-infercnv-ref-roc
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gx109_infercnv_ref_roc.out
#PBS -e gx109_infercnv_ref_roc.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/infercnv.ref.roc.R \
#  <cnv type>     \
#  <data dir>      \
#  <subdir prefix>   \
#  <truth file>    \
#  <out dir>   \
#  <out prefix>  \
#  <cutoff max size>

/usr/bin/time -v Rscript $work_dir/infercnv.ref.roc.R \
  gain \
  $project_dir/output/GX109_infercnv \
  GX109_   \
  $project_dir/output/GX109_evaluate/truth/GX109.exp.isec.copy.gain.binary.matrix.rds \
  $project_dir/output/GX109_infercnv_ref/roc  \
  GX109.infercnv.exp.copy.gain \
  1000

/usr/bin/time -v Rscript $work_dir/infercnv.ref.roc.R \
  loss \
  $project_dir/output/GX109_infercnv \
  GX109_   \
  $project_dir/output/GX109_evaluate/truth/GX109.exp.isec.copy.loss.binary.matrix.rds \
  $project_dir/output/GX109_infercnv_ref/roc  \
  GX109.infercnv.exp.copy.loss \
  1000

set +ux
conda deactivate
echo [`basename $0`] All Done!

