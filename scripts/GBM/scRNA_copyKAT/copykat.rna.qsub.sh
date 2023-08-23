#!/bin/bash
#PBS -N gbm-copykat
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gbm_copykat.out
#PBS -e gbm_copykat.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/copykat.rna.R \
#  <sample id>     \
#  <matrix dir>   \
#  <cell anno file>  \
#  <control cell type> \
#  <number of cores>  \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/copykat.rna.R \
  GBM  \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/matrix  \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/anno/GBM_10xscrna_4416cell.cell_anno.2column.tsv  \
  "Normal"   \
  20  \
  $work_dir

set +ux
conda deactivate
echo "All Done!"

