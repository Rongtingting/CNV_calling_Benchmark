#!/bin/bash
#PBS -N scDNA_extract_ground_truth
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=100g,walltime=100:00:00
#PBS -o scDNA_extract_ground_truth.out
#PBS -e scDNA_extract_ground_truth.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclbm/CNV_calling_Benchmark/v2

#Rscript $work_dir/scDNA_extract_ground_truth.R \
#  <sample id>     \
#  <cnv file>     \
#  <target node>  \
#  <gain regions>   \
#  <loss regions>   \
#  <out dir>  \
#  <utils>

/usr/bin/time -v Rscript $work_dir/scDNA_extract_ground_truth.R \
  GX109  \
  $project_dir/input/GX109/scDNA/GX109-T1c-CNV-group_1630-heatmap.csv \
  1577  \
  chr8,chr20  \
  chr12,chr18 \
  $project_dir/output/GX109_preprocess  \
  $project_dir/scripts/utils/utils.R

set +ux
conda deactivate
echo [`basename $0`] All Done!

