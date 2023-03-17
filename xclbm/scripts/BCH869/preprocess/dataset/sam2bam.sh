#!/bin/bash

in_dir=~/projects/xclone/result/BCH869_010421/aln
out_dir=~/projects/xclone/result/BCH869_010421/sort
mkdir -p $out_dir &> /dev/null
bin_samtools=samtools

for f in `ls $in_dir/*.sam`; do
    sample=`basename ${f%%.*}`
    tmp_bam=$out_dir/${sample}.bam
    bam=$out_dir/${sample}.sort.bam
    echo "=> $sample"
    cmd="$bin_samtools view -h -b $f > $tmp_bam"
    echo "$cmd" && eval $cmd
    cmd="$bin_samtools sort -O BAM $tmp_bam > $bam"
    echo "$cmd" && eval $cmd
    cmd="rm $tmp_bam"
    echo "$cmd" && eval $cmd
    cmd="$bin_samtools index $bam"
    echo "$cmd" && eval $cmd
    echo
done
