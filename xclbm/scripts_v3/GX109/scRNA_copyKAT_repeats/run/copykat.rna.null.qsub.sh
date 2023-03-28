#!/bin/bash
# Author:Rongting 
# Date:2021-06-07
# contact:rthuang@connect.hku.hk
#PBS -N gx109-copykat-null
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=400g,walltime=400:00:00
#PBS -o gx109_copykat_null.out
#PBS -e gx109_copykat_null.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#Rscript $work_dir/copykat.rna.R \
#  <sample id>     \
#  <matrix dir>   \
#  <cell anno file>  \
#  <control cell type> \
#  <out dir>

for i in 1 2 3; do
  /usr/bin/time -v Rscript $work_dir/copykat.rna.R \
    GX109  \
    $project_dir/input/GX109/scRNA/helen_filtered_matrices  \
    $project_dir/input/GX109/scRNA/helen_filtered_matrices/cell_type.tsv \
    NULL \
    $project_dir/output/GX109_copykat_repeats/run/null_$i
done

set +ux
conda deactivate
echo "[`basename $0`] All Done!"

