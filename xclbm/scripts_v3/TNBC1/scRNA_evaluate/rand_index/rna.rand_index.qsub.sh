#!/bin/bash
#PBS -N tnbc1-randidx
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o tnbc1_randidx.out
#PBS -e tnbc1_randidx.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/rna.rand_index.R \
#  <sample id>     \
#  <data dir>      \
#  <data suffix>   \
#  <all k>           \
#  <truth file>    \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/rna.rand_index.R \
  TNBC1  \
  $project_dir/output/TNBC1_evaluate/cluster  \
  cluster.k.*.rds  \
  2,3,4,5,6,7,8  \
  $project_dir/input/TNBC1/scRNA/TNBC1.cluster.ground.truth.csv \
  $project_dir/output/TNBC1_evaluate/rand_index

set +ux
conda deactivate
echo [`basename $0`] All Done!

