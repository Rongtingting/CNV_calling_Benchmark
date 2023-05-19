#!/bin/bash
#PBS -N numbat_preprocess_allele
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=100g,walltime=100:00:00
#PBS -o numbat_preprocess_allele.out
#PBS -e numbat_preprocess_allele.err

source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#usage: pileup_and_phase.R [-h] --label LABEL --samples SAMPLES --bams BAMS
#                          [--barcodes BARCODES] --gmap GMAP [--eagle EAGLE]
#                          --snpvcf SNPVCF --paneldir PANELDIR --outdir OUTDIR
#                          --ncores NCORES [--UMItag UMITAG]
#                          [--cellTAG CELLTAG] [--smartseq] [--bulk]
#
#Run SNP pileup and phasing with 1000G
#
#Arguments:
#  -h, --help           show this help message and exit
#  --label LABEL        Individual label
#  --samples SAMPLES    Sample names, comma delimited
#  --bams BAMS          BAM files, one per sample, comma delimited
#  --barcodes BARCODES  Cell barcode files, one per sample, comma delimited
#  --gmap GMAP          Path to genetic map provided by Eagle2 (e.g.
#                       Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz)
#  --eagle EAGLE        Path to Eagle2 binary file
#  --snpvcf SNPVCF      SNP VCF for pileup
#  --paneldir PANELDIR  Directory to phasing reference panel (BCF files)
#  --outdir OUTDIR      Output directory
#  --ncores NCORES      Number of cores

/usr/bin/time -v Rscript $work_dir/pileup_and_phase.R \
  --label TNBC1    \
  --samples TNBC1  \
  --bams /groups/cgsd/xianjie/data/dataset/TNBC1/bam/BAM_TNBC1.bam  \
  --barcodes /groups/cgsd/xianjie/data/dataset/TNBC1/bam/new_barcodes.txt  \
  --gmap /groups/cgsd/xianjie/data/refapp/eagle/Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz \
  --eagle ~/.anaconda3/envs/XCLBM/bin/eagle  \
  --snpvcf /groups/cgsd/xianjie/data/refapp/numbat/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz  \
  --paneldir /groups/cgsd/xianjie/data/refapp/numbat/1000G_hg38  \
  --outdir $work_dir/allele  \
  --ncores 10

set +ux
conda deactivate
echo [`basename $0`] All Done!

