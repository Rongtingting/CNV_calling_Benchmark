#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N gx109-extract
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gx109_extract.out
#PBS -e gx109_extract.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/rna.extract.exp.R \
#  <sample id>     \
#  <meta file>     \
#  <truth cell>    \
#  <truth gene>    \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/rna.extract.exp.R \
  GX109  \
  $work_dir/rna.extract.exp.meta.tsv  \
  $project_dir/output/GX109_evaluate/extract/GX109.isec.cell.barcodes.tsv \
  $project_dir/output/GX109_evaluate/extract/GX109.isec.gene.tsv \
  $project_dir/output/GX109_copykat_repeats/extract

set +ux
conda deactivate
echo [`basename $0`] All Done!

