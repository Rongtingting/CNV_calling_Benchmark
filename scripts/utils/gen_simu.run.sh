#!/bin/bash
# gen_plot.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
result_dir=/home/xianjie/debug/test-xclbm/simulation
sid=GX109-T1c    # sample ID
sp=GX109         # script prefix
N=5
dat_root_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate simulation scripts.\n"
out_dir=$result_dir
python  $repo_scripts_dir/utils/gen_simu.py  \
  --sid  $sid   \
  --sp  $sp        \
  --dir10x  $dat_root_dir/matrix/helen_filtered_matrices    \
  --targetCellTypes  "immune cells"     \
  --N  $N              \
  --outdir  $out_dir     \
  --repoScripts  $repo_scripts_dir   \
  --cellAnno  $dat_root_dir/anno/GX109-T1c_scRNA_annotation_2column.tsv   \
  --geneAnno  $dat_root_dir/matrix/helen_filtered_matrices/genes.tsv    \
  --geneIsRow  True       \
  --sortCells  True       \
  --seed  123

