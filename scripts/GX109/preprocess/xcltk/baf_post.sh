#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_baf_post=/home/xianjie/projects/xclone/result/xcltk_010421/xcltk/preprocess/baf_post_impute/baf_post_impute.sh

dna_barcode0=/groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/per_cell_summary_metrics.csv
dna_barcode=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109.dna.barcodes.tsv
cat $dna_barcode0 | awk 'NR > 1' | awk -F ',' '{print $1}' > $dna_barcode
atac_barcode=/groups/cgsd/yuanhua/CPOS_Data_20200408/10XATAC/LeungSY_10XATAC_SS-190506-02a/cellranger/GX109-T1c-ATAC/atac_GX109-T1c-ATAC/outs/filtered_tf_bc_matrix/barcodes.tsv

rid=GX109-fby-phase-dna
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S dna \
    -b $dna_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/possorted_bam.bam \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-fby-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=GX109-fby-phase-rna
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S rna \
    -b /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/filtered_gene_bc_matrices/GRCh38/barcodes.tsv \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/possorted_genome_bam.bam \
    -u UR \
    -f /home/xianjie/data/cellranger/refdata-cellranger-GRCh38-1.2.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-fby-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=GX109-fby-phase-atac
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S atac \
    -b $atac_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XATAC/LeungSY_10XATAC_SS-190506-02a/cellranger/GX109-T1c-ATAC/atac_GX109-T1c-ATAC/outs/possorted_bam.bam \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-fby-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=GX109-csp-phase-dna
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S dna \
    -b $dna_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/possorted_bam.bam \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-csp-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=GX109-csp-phase-rna
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S rna \
    -b /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/filtered_gene_bc_matrices/GRCh38/barcodes.tsv \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/possorted_genome_bam.bam \
    -u UR \
    -f /home/xianjie/data/cellranger/refdata-cellranger-GRCh38-1.2.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-csp-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=GX109-csp-phase-atac
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S atac \
    -b $atac_barcode \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XATAC/LeungSY_10XATAC_SS-190506-02a/cellranger/GX109-T1c-ATAC/atac_GX109-T1c-ATAC/outs/possorted_bam.bam \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -P phase \
    -v /home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/GX109-csp-phase/all.vcf.gz \
    -B ~/data/xclone/hg38.gene.region.lst.tsv \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

