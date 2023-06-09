#!/bin/bash
#PBS -N gx109-copykat
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gx109_copykat.out
#PBS -e gx109_copykat.err

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
  GX109  \
  /groups/cgsd/xianjie/data/dataset/GX109/scRNA/matrix/helen_filtered_matrices   \
  /groups/cgsd/xianjie/data/dataset/GX109/scRNA/anno/GX109-T1c_scRNA_annotation_2column.tsv  \
  "immune cells"   \
  20  \
  $work_dir

set +ux
conda deactivate
echo "All Done!"

