#!/bin/bash

work_dir=`cd $(dirname $0); pwd`
bin_baf_pre=/home/xianjie/projects/xclone/result/xcltk_010421/xcltk/preprocess/baf_pre_impute/baf_pre_impute.sh

rid=GX109-fby-pre
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_pre \
    -N $rid \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/possorted_bam.bam  \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -C freebayes \
    -O $out_dir \
    -p 10 \
    -c $work_dir/baf_pre.cfg


rid=GX109-csp-pre
out_dir=/home/xianjie/projects/xclone/result/xcltk_010421/result/GX109/$rid
mkdir -p $out_dir &> /dev/null

qsub -N $rid -q cgsd -l nodes=1:ppn=10,mem=100gb,walltime=100:00:00 \
  -o $out_dir/${rid}.out -e $out_dir/${rid}.err -- \
  $bin_baf_pre \
    -N $rid \
    -s /groups/cgsd/yuanhua/CPOS_Data_20200408/10XCNV/LeungSY_10XCNV_SS-190409-04d/cellranger/GX109-T1c-CNV/cnv_GX109-T1c-CNV/outs/possorted_bam.bam  \
    -f /home/xianjie/data/cellranger/refdata-GRCh38-1.0.0/fasta/genome.fa \
    -g 38 \
    -C cellsnp-lite \
    -O $out_dir \
    -p 10 \
    -c $work_dir/baf_pre.cfg
