#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N bch869-casper
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch869_casper.out
#PBS -e bch869_casper.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/casper.rna.R \
#  <sample id>     \
#  <expression file>    \
#  <cell anno file>    \
#  <control cell type> \
#  <gene anno file>  \
#  <hg version>   \
#  <baf dir>     \
#  <baf suffix>  \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.R \
  BCH869  \
  $project_dir/input/BCH869/scRNA/BCH869.combined.expr.csv \
  $project_dir/output/BCH869_copykat_null/BCH869_copykat_prediction.txt \
  diploid  \
  $project_dir/output/BCH869_preprocess/BCH869.combined.expr.genes.hgnc.hg19.rds \
  19    \
  $project_dir/input/BCH869/scRNA   \
  snp.BAF.tsv  \
  $project_dir/output/BCH869_casper_diploid

/usr/bin/time -v Rscript $work_dir/casper.rna.R \
  BCH869  \
  $project_dir/output/BCH869_preprocess/BCH869.492.expr.csv \
  $project_dir/output/BCH869_copykat_null_492/BCH869_copykat_prediction.txt \
  diploid  \
  $project_dir/output/BCH869_preprocess/BCH869.combined.expr.genes.hgnc.hg19.rds \
  19    \
  $project_dir/input/BCH869/scRNA   \
  snp.BAF.tsv  \
  $project_dir/output/BCH869_casper_diploid_492

set +ux
conda deactivate
echo "[`basename $0`] All Done!"

