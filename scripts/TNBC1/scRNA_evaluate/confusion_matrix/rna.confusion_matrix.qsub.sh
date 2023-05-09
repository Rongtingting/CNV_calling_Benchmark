#!/bin/bash
#PBS -N tnbc1-conf-mtx
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o tnbc1_conf_mtx.out
#PBS -e tnbc1_conf_mtx.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/rna.confusion_matrix.R \
#  <data dir>   \
#  <data suffix>  \
#  <tool cluster labels>  \
#  <truth file>  \
#  <truth cluster labels> \
#  <out dir>  \
#  <out prefix>

# Note that both <truth cluster labels> and <tool cluster labels> are 
# in the order of cluster 1,2,3 of the truth

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/TNBC1_evaluate/cluster/k3  \
  cluster.k.*.rds  \
  "Clone A,Clone B,Normal"  \
  $project_dir/input/TNBC1/scRNA/TNBC1.cluster.ground.truth.csv \
  "Clone A,Clone B,Normal"  \
  $project_dir/output/TNBC1_evaluate/confusion_matrix  \
  TNBC1

set +ux
conda deactivate
echo [`basename $0`] All Done!

