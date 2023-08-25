#!/bin/bash
#PBS -N gbm-casper-preprocess
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o gbm_casper_preprocess.out
#PBS -e gbm_casper_preprocess.err

source ~/.bashrc
conda activate F 

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

bam_file=/groups/cgsd/xianjie/data/dataset/GBM/10xscrna_4416/bam/possorted_genome_bam.bam
genome_list=/groups/cgsd/xianjie/data/refapp/casper/hg38.list
sample_dir=/groups/cgsd/xianjie/result/xclbm2/GBM/GBM_preprocess_230823/BAFExtract/sample
genome_fasta_pileup_dir=/groups/cgsd/xianjie/data/refapp/casper/hg38_bin
output_baf_file=/groups/cgsd/xianjie/result/xclbm2/GBM/GBM_preprocess_230823/BAFExtract/BAF_GBM

samtools view ${bam_file} | \
    /home/xianjie/tools/BAFExtract/bin/BAFExtract  \
        -generate_compressed_pileup_per_SAM    \
        stdin \
        ${genome_list}   \
        ${sample_dir}     \
        50     \
        0   

/home/xianjie/tools/BAFExtract/bin/BAFExtract \
    -get_SNVs_per_pileup   \
    ${genome_list}       \
    ${sample_dir}        \
    ${genome_fasta_pileup_dir} \
    20 \
    4   \
    0.1 \
    ${output_baf_file}

set +ux
conda deactivate
echo "All Done!"


