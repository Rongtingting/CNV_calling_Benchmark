#!/bin/bash
# gen_call_GX109.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
result_dir=/home/xianjie/debug/test-xclbm/calling
sid=GX109    # sample ID
dat_root_dir=/groups/cgsd/xianjie/data/dataset/GX109/scRNA


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate calling scripts.\n"
out_dir=$result_dir
python  $repo_scripts_dir/utils/gen_call_GX109.py  \
  --sid  $sid   \
  --bam  $dat_root_dir/bam/raw_GX109-T1c/possorted_genome_bam.bam  \
  --barcodes  $dat_root_dir/matrix/helen_filtered_matrices/barcodes.tsv  \
  --cellTAG  CB       \
  --dir10x  $dat_root_dir/matrix/helen_filtered_matrices    \
  --refCellTypes  "immune cells"     \
  --outdir  $out_dir     \
  --repoScripts  $repo_scripts_dir   \
  --cellAnno  $dat_root_dir/anno/GX109-T1c_scRNA_annotation_2column.tsv   \
  --geneAnno  /groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt  \
  --hgVersion  38   \
  --geneIsRow  True       \
  --casperBAF  $dat_root_dir/matrix   \
  --casperBAFSuffix  "snp.BAF.tsv"   \
  --casperGeneAnno  $dat_root_dir/matrix/GX109.helen_filtered.matrix.genes.hg38.hgnc.rds  \
  --numbatGmap  /groups/cgsd/xianjie/data/refapp/eagle/Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz  \
  --numbatEagle  /home/xianjie/.anaconda3/envs/XCLBM/bin/eagle   \
  --numbatSNP  /groups/cgsd/xianjie/data/refapp/numbat/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz  \
  --numbatPanel  /groups/cgsd/xianjie/data/refapp/numbat/1000G_hg38  \
  --ncores  10

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

