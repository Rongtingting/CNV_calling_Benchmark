#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_xcltk=~/.anaconda3/envs/F/bin/xcltk

dna_barcode0=/groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/per_cell_summary_metrics.csv
dna_barcode=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109.dna.barcodes.tsv
cat $dna_barcode0 | awk 'NR > 1' | awk -F ',' '{print $1}' > $dna_barcode
atac_barcode=/groups/cgsd/yuanhua/CPOS_Data_20200408/10XATAC/LeungSY_10XATAC_SS-190506-02a/cellranger/GX109-T1c-ATAC/atac_GX109-T1c-ATAC/outs/filtered_tf_bc_matrix/barcodes.tsv

reg_file=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/rdr.hg38.blocks.tsv
$bin_xcltk convert -B 50 -H 38 > $reg_file

rid=GX109-rdr-dna-even
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_xcltk basefc \
    -b $dna_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/possorted_bam.bam \
    -p 10     \
    -O $out_dir \
    -r $reg_file \
    -T tsv \
    --cellTAG CB \
    --UMItag None \
    --minLEN 30 \
    --minMAPQ 20 \
    --maxFLAG 255

rid=GX109-rdr-rna-even
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_xcltk basefc \
    -b /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/filtered_gene_bc_matrices/GRCh38/barcodes.tsv \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/possorted_genome_bam.bam \
    -p 10     \
    -O $out_dir \
    -r $reg_file \
    -T tsv \
    --cellTAG CB \
    --UMItag UR \
    --minLEN 30 \
    --minMAPQ 20 \
    --maxFLAG 4096

rid=GX109-rdr-atac-even
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_xcltk basefc \
    -b $atac_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XATAC/LeungSY_10XATAC_SS-190506-02a/cellranger/GX109-T1c-ATAC/atac_GX109-T1c-ATAC/outs/possorted_bam.bam \
    -p 10     \
    -O $out_dir \
    -r $reg_file \
    -T tsv \
    --cellTAG CB \
    --UMItag None \
    --minLEN 30 \
    --minMAPQ 20 \
    --maxFLAG 255

