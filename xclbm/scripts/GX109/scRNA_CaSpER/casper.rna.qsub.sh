#!/bin/bash
#PBS -N gx109-casper
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gx109_casper.out
#PBS -e gx109_casper.err

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
  GX109  \
  /groups/cgsd/xianjie/result/xclbm/data/GX109/scRNA/helen_filtered_matrices  \
  /groups/cgsd/xianjie/result/xclbm/v4/GX109/data/GX109-T1c_scRNA_annotation_2column.tsv  \
  "immune cells"    \
  /groups/cgsd/xianjie/result/xclbm/res-v2/GX109_preprocess/GX109.helen_filtered.matrix.genes.hg38.hgnc.rds \
  38    \
  /groups/cgsd/xianjie/result/xclbm/data/GX109/scRNA  \
  snp.BAF.tsv  \
  $work_dir

#Rscript $work_dir/casper.rna.plot.R  \
#  <sample id>  \
#  <final chr mat> \
#  <loh median data> \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.plot.R \
  GX109  \
  $work_dir/GX109.final_chr_mat.rds \
  $work_dir/GX109.loh.median.filtered.data.rds \
  $work_dir

set +ux
conda deactivate
echo "[`basename $0`] All Done!"

