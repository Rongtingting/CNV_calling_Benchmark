#!/bin/bash
#PBS -N gx109-infercnv
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=100:00:00
#PBS -o gx109_infercnv.out
#PBS -e gx109_infercnv.err

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
#  <matrix dir>   \
#  <anno file>     \
#  <gene file>     \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/infercnv.rna.R \
  GX109  \
  /groups/cgsd/xianjie/result/xclbm/data/GX109/scRNA/helen_filtered_matrices  \
  /groups/cgsd/xianjie/result/xclbm/v4/GX109/data/GX109-T1c_scRNA_annotation_2column.tsv  \
  /groups/cgsd/xianjie/result/xclbm/data/common/hg38_gene_note_noheader_unique.txt \
  $work_dir

set +ux
conda deactivate
echo [`basename $0`] All Done!"

