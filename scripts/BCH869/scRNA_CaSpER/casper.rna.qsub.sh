#!/bin/bash
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
  /groups/cgsd/xianjie/data/dataset/BCH869/matrix/BCH869.492.expr.csv \
  /groups/cgsd/xianjie/data/dataset/BCH869/anno/BCH869.492.cell.anno.2type.tsv \
  Normal  \
  /groups/cgsd/xianjie/data/dataset/BCH869/matrix/BCH869.combined.expr.genes.hgnc.hg19.rds \
  19    \
  /groups/cgsd/xianjie/data/dataset/BCH869/matrix   \
  snp.BAF.tsv  \
  $work_dir/BCH869_casper_normal_492

set +ux
conda deactivate
echo "[`basename $0`] All Done!"

