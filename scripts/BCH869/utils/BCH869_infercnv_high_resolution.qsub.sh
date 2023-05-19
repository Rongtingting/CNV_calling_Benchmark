#!/bin/bash
#PBS -N bch-infercnv
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o bch_infercnv.out
#PBS -e bch_infercnv.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

/usr/bin/time -v Rscript $work_dir/BCH869_infercnv_high_resolution.R

set +ux
conda deactivate
echo [`basename $0`] All Done!"

