#!/bin/bash
#PBS -N tnbc1-cluster
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o tnbc1_cluster.out
#PBS -e tnbc1_cluster.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/rna.cluster.R \
#  <sample id>     \
#  <meta file>     \
#  <all k>        \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/rna.cluster.R \
  TNBC1  \
  $work_dir/rna.cluster.meta.tsv  \
  2,3,4,5,6,7,8   \
  $project_dir/output/TNBC1_evaluate/cluster

set +ux
conda deactivate
echo [`basename $0`] All Done!

