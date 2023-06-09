#!/bin/bash
# simu_data.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
result_dir=/home/xianjie/debug/test-xclbm/simulation
sid=GX109-T1c    # sample ID
N=5
dat_root_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate simulation scripts.\n"
out_dir=$result_dir
python  $repo_scripts_dir/utils/simulation/simu_data.py  \
  --sid  $sid   \
  --bam  $dat_root_dir/bam/raw_GX109-T1c/possorted_genome_bam.bam  \
  --cellTAG  CB       \
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

