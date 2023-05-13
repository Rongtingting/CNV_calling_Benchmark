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
#  <ref cell type>  \
#  <gene file>     \
#  <out dir>

/usr/bin/time -v Rscript $work_dir/infercnv.rna.R \
  GX109  \
  /groups/cgsd/xianjie/data/dataset/GX109/scRNA/matrix/helen_filtered_matrices  \
  /groups/cgsd/xianjie/data/dataset/GX109/scRNA/anno/GX109-T1c_scRNA_annotation_2column.tsv  \
  "immune cells"     \
  /groups/cgsd/xianjie/data/refapp/xclone/hg38_gene_note_noheader_unique.txt  \
  $work_dir

set +ux
conda deactivate
echo All Done!

