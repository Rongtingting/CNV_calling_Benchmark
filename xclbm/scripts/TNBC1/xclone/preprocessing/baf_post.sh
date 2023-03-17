#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_baf_post=$work_dir/xcltk/preprocess/baf_post_impute/baf_post_impute.sh
fa=~/data/cellranger/refdata-cellranger-GRCh38-1.2.0/fasta/genome.fa
reg_fet=~/data/xclone/hg38.gene.region.lst.tsv

bam=/groups/cgsd/rthuang/data/copyKAT/tnbc1/BAM_TNBC1.bam
barcode=$work_dir/barcodes.lst

rid=kat-csp-post
vcf=$work_dir/result/kat/kat-csp.vcfs/all.vcf.gz
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S rna \
    -b $barcode \
    -s $bam \
    -u UB \
    -f $fa \
    -g 38 \
    -P phase \
    -v $vcf \
    -B $reg_fet \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg

rid=kat-fby-post
vcf=$work_dir/result/kat/kat-fby.vcfs/all.vcf.gz
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_post \
    -N $rid \
    -S rna \
    -b $barcode \
    -s $bam \
    -u UB \
    -f $fa \
    -g 38 \
    -P phase \
    -v $vcf \
    -B $reg_fet \
    -p 10     \
    -O $out_dir \
    -c $work_dir/baf_post.cfg
