#!/bin/bash
# gen_call.BCH869.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
repo_xcltk_dir=/home/xianjie/projects/xcltk/preprocess
result_dir=/home/xianjie/debug/test-xclbm/calling/BCH869
sid=BCH869    # sample ID
dat_root_dir=/groups/cgsd/xianjie/data/dataset/BCH869


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate calling scripts.\n"
out_dir=$result_dir
python  $repo_scripts_dir/utils/gen_call.BCH869.py  \
  --sid  $sid   \
  --bam  $dat_root_dir/bam/BCH869.492.bam.lst  \
  --barcodes  $dat_root_dir/bam/BCH869.492.id.lst  \
  --expr  $dat_root_dir/matrix/BCH869.492.expr.csv  \
  --refCellTypes  "Normal"     \
  --outdir  $out_dir     \
  --repoScripts  $repo_scripts_dir   \
  --repoXCL  $repo_xcltk_dir  \
  --cellAnno  $dat_root_dir/anno/BCH869.492.cell.anno.2type.tsv  \
  --geneAnno  /groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg19_update.txt  \
  --hgVersion  19   \
  --casperBAF  $dat_root_dir/matrix   \
  --casperBAFSuffix  "snp.BAF.tsv"   \
  --casperGeneAnno  $dat_root_dir/matrix/BCH869.combined.expr.genes.hgnc.hg19.rds  \
  --infercnvGeneAnno  /groups/cgsd/xianjie/data/refapp/xclone/hg19.cellranger.genes.sort.uniq.tsv  \
  --numbatCellAnno  $dat_root_dir/anno/BCH869.numbat.3ref.cell.anno.tsv  \
  --numbatDir10x  $dat_root_dir/matrix/sim_matrix  \
  --numbatGmap  /groups/cgsd/xianjie/data/refapp/eagle/Eagle_v2.4.1/tables/genetic_map_hg19_withX.txt.gz  \
  --numbatEagle  /home/xianjie/.anaconda3/envs/XCLBM/bin/eagle   \
  --numbatSNP  /groups/cgsd/xianjie/data/refapp/numbat/genome1K.phase3.SNP_AF5e2.chr1toX.hg19.vcf.gz  \
  --numbatPanel  /groups/cgsd/xianjie/data/refapp/numbat/1000G_hg19  \
  --xcloneBAM  $dat_root_dir/bam/merge_492/BCH869.merge.492.rg.bam  \
  --xcloneBarcodes  $dat_root_dir/bam/merge_492/BCH869.merge.492.rg.barcode.tsv  \
  --xcloneBamFA  /groups/cgsd/xianjie/data/refseq/refdata-cellranger-hg19-3.0.0/fasta/genome.fa  \
  --xcloneSangerFA  /groups/cgsd/xianjie/data/refapp/sanger_imputation/human_g1k_v37.fasta  \
  --xcloneGeneList  $repo_xcltk_dir/data/annotate_genes_hg19_update_20230126.txt  \
  --ncores  10

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

