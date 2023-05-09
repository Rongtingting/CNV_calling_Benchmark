#!/bin/bash
#PBS -N extract_cell_type_annotation
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=100g,walltime=100:00:00
#PBS -o extract_cell_type_annotation.out
#PBS -e extract_cell_type_annotation.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1
raw_anno=$project_dir/input/BCH869/scRNA/BCH869.combined.cell.anno.csv
out_dir=$project_dir/output/BCH869_preprocess
if [ ! -d $out_dir ]; then
  mkdir -p $out_dir
fi

cat $raw_anno | \
  awk -F',' 'BEGIN { printf("cell_id\tcell_type\n") }
             NR > 1 { 
               gsub("-", ".", $2);
               gsub(" ", "_", $3);
               printf("%s\t%s\n", $2, $3) 
             }' | \
  sed 's/"//g' \
  > $out_dir/BCH869.636.cell.anno3.tsv

cat $out_dir/BCH869.636.cell.anno3.tsv | \
  awk 'NR == 1 { print } 
       NR > 1 {
         if ($2 != "Malignant") { $2 = "Normal" }
         printf("%s\t%s\n", $1, $2)
       }' \
  > $out_dir/BCH869.636.cell.anno2.tsv

cat $out_dir/BCH869.636.cell.anno3.tsv | \
  awk 'NR == 1 || $1 ~ /^BCH869/' \
  > $out_dir/BCH869.492.cell.anno3.tsv

cat $out_dir/BCH869.636.cell.anno2.tsv | \
  awk 'NR == 1 || $1 ~ /^BCH869/' \
  > $out_dir/BCH869.492.cell.anno2.tsv

set +ux
conda deactivate
echo [`basename $0`] All Done!

