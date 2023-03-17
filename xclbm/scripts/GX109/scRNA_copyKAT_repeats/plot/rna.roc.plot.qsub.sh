#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N gx109-roc-plot
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gx109_roc_plot.out
#PBS -e gx109_roc_plot.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

if [ ! -d "$project_dir/output/GX109_copykat_repeats/plot" ]; then
  mkdir -p $project_dir/output/GX109_copykat_repeats/plot
fi

#Rscript $work_dir/rna.roc.plot.R \
#  <data dir>  \
#  <roc suffix> \
#  <auc file>  \
#  <out file>  \
#  <title>  \
#  <table xmin>  \
#  <table ymin>  

/usr/bin/time -v Rscript $work_dir/rna.roc.plot.R \
  $project_dir/output/GX109_copykat_repeats/roc  \
  copy.gain.*.roc.rds   \
  $project_dir/output/GX109_copykat_repeats/roc/GX109.isec.exp.copy.gain.auc.tsv \
  $project_dir/output/GX109_copykat_repeats/plot/GX109.isec.exp.copy.gain.roc.jpg \
  "GX109 ROC Curve for Copy Gain"  \
  0.6  \
  -0.54

/usr/bin/time -v Rscript $work_dir/rna.roc.plot.R \
  $project_dir/output/GX109_copykat_repeats/roc  \
  copy.loss.*.roc.rds   \
  $project_dir/output/GX109_copykat_repeats/roc/GX109.isec.exp.copy.loss.auc.tsv \
  $project_dir/output/GX109_copykat_repeats/plot/GX109.isec.exp.copy.loss.roc.jpg \
  "GX109 ROC Curve for Copy Loss"  \
  0.6  \
  -0.54

set +ux
conda deactivate
echo [`basename $0`] All Done!

