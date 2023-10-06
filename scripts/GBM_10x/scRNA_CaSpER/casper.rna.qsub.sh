#!/bin/bash
#PBS -N gbm-casper
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gbm_casper.out
#PBS -e gbm_casper.err

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
#  <matrix dir>   \
#  <cell anno file>    \
#  <control cell type> \
#  <gene anno file>  \
#  <hg version>   \
#  <baf dir>     \
#  <baf suffix>  \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.R \
  GBM  \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/matrix  \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/anno/GBM_10xscrna_4416cell.cell_anno.2column.tsv  \
  "Normal"    \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/anno/GBM.genes.hg38.hgnc.rds  \
  38    \
  /groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/anno    \
  snp.BAF.tsv  \
  $work_dir

#Rscript $work_dir/casper.rna.plot.R  \
#  <sample id>  \
#  <final chr mat> \
#  <loh median data> \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.plot.R \
  GBM  \
  $work_dir/GBM.final_chr_mat.rds \
  $work_dir/GBM.loh.median.filtered.data.rds \
  $work_dir

set +ux
conda deactivate
echo "All Done!"

