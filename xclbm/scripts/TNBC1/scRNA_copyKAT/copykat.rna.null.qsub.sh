#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N tnbc1-copykat
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o tnbc1_copykat.out
#PBS -e tnbc1_copykat.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/copykat.rna.R \
#  <sample id>     \
#  <expression file>   \
#  <cell anno>    \
#  <control cell type> \
#  <number of cores>   \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/copykat.rna.R \
  TNBC1  \
  $project_dir/input/TNBC1/scRNA/TNBC1.combined.expr.tsv \
  $project_dir/output/TNBC1_preprocess/TNBC1.combined.cell.anno.tsv \
  NULL  \
  20   \
  $project_dir/output/TNBC1_copykat_null

set +ux
conda deactivate
echo "[`basename $0`] All Done!"

