#!/bin/bash
#PBS -N sort_clone_anno
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=100g,walltime=100:00:00
#PBS -o sort_clone_anno.out
#PBS -e sort_clone_anno.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

out_fn=$project_dir/output/BCH869_preprocess/BCH869.clone.anno.sort.csv
echo ",clone_ID_paper" > $out_fn

cat $project_dir/input/BCH869/scRNA/BCH869.clone.anno.txt | \
  sort -k1,1 | \
  tr ' ' ',' | \
  tr '-' '.' | \
  sed 's/BT_869/BCH869/' >> $out_fn

set +ux
conda deactivate
echo [`basename $0`] All Done!

