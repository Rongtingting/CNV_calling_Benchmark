#!/bin/bash
#PBS -N install_dependency
#PBS -q cgsd
#PBS -l nodes=1:ppn=2,mem=20gb,walltime=10:00:00
#PBS -o install_dependency.out
#PBS -e install_dependency.err

source ~/.bashrc
conda activate XCLBM

R=Rscript

# core part
work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi
src=$work_dir/install_dep_pkg.R

cat <<EOF > $src
devtools::install_github("single-cell-genetics/cardelino", build_vignettes = FALSE)
devtools::install_github("akdess/CaSpER", upgrade = "always")
devtools::install_github("navinlabcode/copykat", upgrade = "always")
if (!requireNamespace("BiocManager", quietly = TRUE))
     install.packages("BiocManager")
BiocManager::install("infercnv")
install.packages("numbat", repos = "http://cran.us.r-project.org")
install.packages("Seurat", repos = "http://cran.us.r-project.org")
#devtools::install_github('JEFworks/HoneyBADGER')
#if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
#
#BiocManager::install("GenomicRanges")
EOF

chmod u+x $src
$R $src
rm $src

echo "All Done!"

