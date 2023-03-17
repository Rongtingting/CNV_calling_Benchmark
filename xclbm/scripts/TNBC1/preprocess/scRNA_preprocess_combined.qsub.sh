#!/bin/bash
#PBS -N tnbc1-pre-combined
#PBS -q cgsd
#PBS -l nodes=1:ppn=20,mem=200g,walltime=400:00:00
#PBS -o tnbc1_pre_combined.out
#PBS -e tnbc1_pre_combined.err

source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux  

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
  work_dir=$PBS_O_WORKDIR
fi

project_dir=~/projects/xclone/xcl_bm/CNV_calling_Benchmark/v1

if [ ! -d "$project_dir/output/TNBC1_preprocess" ]; then
  mkdir -p $project_dir/output/TNBC1_preprocess
fi

# extract expression matrix
#expr_mtx=$project_dir/output/TNBC1_preprocess/TNBC1.combined.expr.tsv
#cat $project_dir/input/TNBC1/scRNA/TNBC1.combined.txt | \
#  awk 'NR < 2 || NR > 3' > $expr_mtx

# extract cell annotation
cell_anno=$project_dir/output/TNBC1_preprocess/TNBC1.combined.cell.anno.tsv
cell_tmp=$project_dir/output/TNBC1_preprocess/tmp.cell.tsv
cell_type_tmp=$project_dir/output/TNBC1_preprocess/tmp.cell_type.tsv
cat $project_dir/input/TNBC1/scRNA/TNBC1.combined.txt | \
  awk 'NR == 1 {print; exit}' | tr '\t' '\n' > $cell_tmp
cat $project_dir/input/TNBC1/scRNA/TNBC1.combined.txt | \
  awk 'NR == 3 {print; exit}' | tr '\t' '\n' | awk 'NR != 1' > $cell_type_tmp
paste $cell_tmp $cell_type_tmp > $cell_anno
rm $cell_tmp
rm $cell_type_tmp

# extract gene list
gene_lst=$project_dir/output/TNBC1_preprocess/TNBC1.combined.genes.raw.tsv
cat $project_dir/input/TNBC1/scRNA/TNBC1.combined.txt | \
  awk 'NR > 3 {print $1}' > $gene_lst

gene_uniq_lst=$project_dir/output/TNBC1_preprocess/TNBC1.combined.genes.sort.uniq.tsv
cat $gene_lst | sort | uniq > $gene_uniq_lst

# annotate genes
#Rscript $work_dir/scRNA_annotate_raw_genes.R \
#  <input gene list>  \
#  <hg version>  \
#  <output anno file>

/usr/bin/time -v Rscript $work_dir/scRNA_annotate_raw_genes.R \
  $gene_uniq_lst  \
  19  \
  $project_dir/output/TNBC1_preprocess/TNBC1.combined.expr.genes.hgnc.hg19.rds

/usr/bin/time -v Rscript $work_dir/scRNA_annotate_raw_genes.R \
  $gene_uniq_lst  \
  38  \
  $project_dir/output/TNBC1_preprocess/TNBC1.combined.expr.genes.hgnc.hg38.rds

set +ux
conda deactivate
echo [`basename $0`] All Done!

