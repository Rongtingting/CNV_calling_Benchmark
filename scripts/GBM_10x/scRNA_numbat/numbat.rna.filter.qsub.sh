#!/bin/bash
#PBS -N numbat
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=200g,walltime=100:00:00
#PBS -o numbat.out
#PBS -e numbat.err

source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

#Rscript $work_dir/numbat.rna.R  \
#  <count matrix>  \
#  <ref expression>  \
#  <allele dataframe>  \
#  <out dir>   \
#  <out prefix>  \
#  <ncores>

/usr/bin/time -v Rscript $work_dir/numbat.rna.R  \
  GBM.numbat.Normal_cells_filtered.count.mtx.rds  \
  GBM.numbat.Normal.ref.gene_by_cell_type.mtx.rds  \
  GBM.numbat.Normal_cells_filtered.allele.dataframe.rds  \
  $work_dir     \
  GBM.numbat.Normal.filter  \
  10

set +ux
conda deactivate
echo [`basename $0`] All Done!

