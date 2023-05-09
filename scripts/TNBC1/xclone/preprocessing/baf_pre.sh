#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_baf_pre=$work_dir/xcltk/preprocess/baf_pre_impute/baf_pre_impute.sh
fa=~/data/cellranger/refdata-cellranger-GRCh38-1.2.0/fasta/genome.fa

bam=/groups/cgsd/rthuang/data/copyKAT/tnbc1/BAM_TNBC1.bam

rid=kat-fby-pre
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=200gb,walltime=300:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_pre \
    -N $rid \
    -s $bam \
    -f $fa \
    -g 38 \
    -C freebayes \
    -d \
    -u UB \
    -O $out_dir \
    -p 10 \
    -c $work_dir/baf_pre.cfg

rid=kat-csp-pre
out_dir=$work_dir/result/kat/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_pre \
    -N $rid \
    -s $bam \
    -f $fa \
    -g 38 \
    -C cellsnp-lite \
    -d \
    -u UB \
    -O $out_dir \
    -p 10 \
    -c $work_dir/baf_pre.cfg
