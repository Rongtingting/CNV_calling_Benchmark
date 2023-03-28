#!/bin/bash
#PBS -N numbat_preprocess_allele_filter_ref
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=100g,walltime=100:00:00
#PBS -o numbat_preprocess_allele_filter_ref.out
#PBS -e numbat_preprocess_allele_filter_ref.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

data_dir=/groups/cgsd/xianjie/result/xclbm/res-v3/BCH869_numbat_preprocess

#Rscript $work_dir/numbat_preprocess_allele_filter_ref.R  \
#  <allele file>  \
#  <ref cells file>   \
#  <ref cell type>  \
#  <out dir>    \
#  <out prefix>  \
#  <save raw> 

/usr/bin/time -v Rscript $work_dir/numbat.preprocess.allele.filter_ref.R  \
  $data_dir/allele/BCH869_allele_counts.tsv.gz  \
  $work_dir/../BCH869.numbat.3.ref.cell.anno.tsv  \
  normal  \
  $data_dir/allele_ref     \
  BCH869.numbat  \
  True

set +ux
conda deactivate
echo [`basename $0`] All Done!

