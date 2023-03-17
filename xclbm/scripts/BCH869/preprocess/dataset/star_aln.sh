#!/bin/bash

fq_dir=/storage/yhhuang/frozenDat/gliomasH3K27M/BCH869/fastq
genome_dir=~/data/genome/refdata-cellranger-hg19-3.0.0/star2
bin_star=~/.conda/envs/CSP/bin/STAR

out_dir=~/projects/xclone/result/BCH869_010421/aln
mkdir -p $out_dir &> /dev/null
log_dir=$out_dir/log/aln
mkdir -p $log_dir &> /dev/null

ncores=4

fq_list=`ls -l $fq_dir | awk '{print $NF}' | xargs -I {} basename {} | sed 's/_R[0-9].*//' | sort -u`
for name in $fq_list; do
    fq1=$fq_dir/${name}_R1.fastq.gz
    fq2=$fq_dir/${name}_R2.fastq.gz
    out_prefix=$out_dir/$name
    out_log=$log_dir/${name}.out
    err_log=$log_dir/${name}.err
    cmd="$bin_star --runThreadN $ncores --genomeDir $genome_dir --readFilesCommand zcat --readFilesIn $fq1 $fq2 --outFileNamePrefix ${out_prefix}."
    echo "$cmd" && eval $cmd
done
