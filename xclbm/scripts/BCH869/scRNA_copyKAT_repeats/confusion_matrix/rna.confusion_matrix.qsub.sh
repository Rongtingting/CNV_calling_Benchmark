#!/bin/bash
#PBS -N bch869-conf-mtx
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch869_conf_mtx.out
#PBS -e bch869_conf_mtx.err

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

i=1   # idx of repeat

# for the 636 cells

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/cluster/k5  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C,Clone_D,Clone_E"  \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  "Clone_1,Clone_2,Clone_3,Clone_4"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/confusion_matrix/k5  \
  BCH869.k5

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/cluster/k4  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C,Clone_D"  \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  "Clone_1,Clone_2,Clone_3,Clone_4"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/confusion_matrix/k4  \
  BCH869.k4

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/cluster/k2  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B"  \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  "Clone_1,Clone_2"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/confusion_matrix/k2  \
  BCH869.k2

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/cluster/k3  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C"  \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  "Clone_1,Clone_2"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate/confusion_matrix/k3  \
  BCH869.k3

# for the 492 cells

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/cluster/k5  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C,Clone_D,Clone_E"  \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  "Clone_1,Clone_2,Clone_3,Clone_4"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/confusion_matrix/k5 \
  BCH869.k5

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/cluster/k4  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C,Clone_D"  \
  $project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv \
  "Clone_1,Clone_2,Clone_3,Clone_4"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/confusion_matrix/k4  \
  BCH869.k4

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/cluster/k2  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B"  \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  "Clone_1,Clone_2"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/confusion_matrix/k2  \
  BCH869.k2

/usr/bin/time -v Rscript $work_dir/rna.confusion_matrix.R \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/cluster/k3  \
  cluster.k.*.rds  \
  "Clone_A,Clone_B,Clone_C"  \
  $project_dir/input/BCH869/scRNA/BCH869.cluster.ground.truth.csv \
  "Clone_1,Clone_2"  \
  $project_dir/output/BCH869_copykat_repeats/rep$i/BCH869_evaluate_492/confusion_matrix/k3  \
  BCH869.k3

set +ux
conda deactivate
echo [`basename $0`] All Done!

