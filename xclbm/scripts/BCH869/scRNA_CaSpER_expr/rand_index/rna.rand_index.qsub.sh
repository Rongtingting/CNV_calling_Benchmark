#!/bin/bash
#PBS -N bch869-randidx
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch869_randidx.out
#PBS -e bch869_randidx.err

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
#  <all k>         \
#  <truth file>    \
#  <out dir>

# for the 636 cells

/usr/bin/time -v Rscript $work_dir/rna.rand_index.R \
  BCH869  \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate/cluster  \
  cluster.k.*.rds  \
  2,3,4,5,6,7,8   \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate/rand_index/k2

/usr/bin/time -v Rscript $work_dir/rna.rand_index.R \
  BCH869  \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate/cluster  \
  cluster.k.*.rds  \
  2,3,4,5,6,7,8   \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate/rand_index/k4

# for the 492 cells

/usr/bin/time -v Rscript $work_dir/rna.rand_index.R \
  BCH869  \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate_492/cluster  \
  cluster.k.*.rds  \
  2,3,4,5,6,7,8   \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate_492/rand_index/k2

/usr/bin/time -v Rscript $work_dir/rna.rand_index.R \
  BCH869  \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate_492/cluster  \
  cluster.k.*.rds  \
  2,3,4,5,6,7,8   \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  $project_dir/output/BCH869_casper_expr/BCH869_evaluate_492/rand_index/k4

set +ux
conda deactivate
echo [`basename $0`] All Done!

