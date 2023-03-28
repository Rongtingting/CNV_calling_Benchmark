#PBS -N bm_bch869
#PBS -q cgsd
#PBS -l nodes=1:ppn=5,mem=200g,walltime=100:00:00
#PBS -o bm_bch869.out
#PBS -e bm_bch869.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

cp scripts/utils/benchmark.R $work_dir
cp scripts/utils/utils.R $work_dir
cp scripts/BCH869/scRNA_evaluate/BCH869.R $work_dir

Rscript $work_dir/BCH869.run.demo.R $work_dir

