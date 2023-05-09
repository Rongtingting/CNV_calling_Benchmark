#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_xcltk=~/.anaconda3/envs/F/bin/xcltk

## even-sized blocks
reg_even=$work_dir/result/rdr.hg38.even.blocks.tsv
$bin_xcltk convert -B 50 -H 38 > $reg_even

## gene-feature blocks
reg_fet=~/data/xclone/hg38.gene.region.lst.tsv

bam=/groups/cgsd/rthuang/data/copyKAT/tnbc1/BAM_TNBC1.bam
barcode=$work_dir/barcodes.lst

rid=kat-rdr-even
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=200gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_xcltk basefc \
    -b $barcode \
    -s $bam \
    -p 10     \
    -O $out_dir \
    -r $reg_even \
    -T tsv \
    --cellTAG CB \
    --UMItag UB \
    --minLEN 30 \
    --minMAPQ 20 \
    --maxFLAG 4096

rid=kat-rdr-fet
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=200gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_xcltk basefc \
    -b $barcode \
    -s $bam \
    -p 10     \
    -O $out_dir \
    -r $reg_fet \
    -T tsv \
    --cellTAG CB \
    --UMItag UB \
    --minLEN 30 \
    --minMAPQ 20 \
    --maxFLAG 4096

