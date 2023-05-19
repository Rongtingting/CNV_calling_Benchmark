#!/bin/bash
#PBS -N bch869-infercnv
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch869_infercnv.out
#PBS -e bch869_infercnv.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/infercnv.rna.R \
#  <sample id>     \
#  <matrix file>   \
#  <anno file>     \
#  <gene file>     \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/infercnv.rna.R \
  BCH869  \
  /groups/cgsd/xianjie/data/dataset/BCH869/matrix/BCH869.492.expr.csv  \
  /groups/cgsd/xianjie/data/dataset/BCH869/anno/BCH869.492.cell.anno.2type.tsv  \
  /groups/cgsd/xianjie/data/refapp/xclone/hg19.cellranger.genes.sort.uniq.tsv \
  $work_dir/BCH869_infercnv_492

set +ux
conda deactivate
echo [`basename $0`] All Done!

