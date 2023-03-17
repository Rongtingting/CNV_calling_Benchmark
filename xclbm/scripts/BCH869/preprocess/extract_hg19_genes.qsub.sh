#!/bin/bash
#PBS -N extract_hg19_genes
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=100g,walltime=100:00:00
#PBS -o extract_hg19_genes.out
#PBS -e extract_hg19_genes.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

#python $work_dir/extract_hg19_genes.py \
#  <in gtf>  \
#  <out tsv>

python $work_dir/extract_hg19_genes.py \
  /home/xianjie/data/cellranger/refdata-cellranger-hg19-3.0.0/genes/genes.gtf  \
  $project_dir/output/BCH869_preprocess/hg19.cellranger.genes.sort.uniq.tsv

set +ux
conda deactivate
echo [`basename $0`] All Done!

