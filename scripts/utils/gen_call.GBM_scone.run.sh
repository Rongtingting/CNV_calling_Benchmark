#!/bin/bash
# gen_call.GBM_scone.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
repo_xcltk_dir=/home/xianjie/projects/xcltk/preprocess
result_dir=/home/xianjie/debug/test-xclbm/calling/BCH869
sid=GBM_scone    # sample ID
dat_root_dir=/groups/cgsd/xianjie/data/dataset/GBM/sconeseq


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate calling scripts.\n"
out_dir=$result_dir
python  $repo_scripts_dir/utils/gen_call.GBM_scone.py  \
  --sid  $sid   \
  --bam  $dat_root_dir/bam/sconeseq.2ndbatch.valid.630.bam.lst  \
  --barcodes  $dat_root_dir/bam/merged/sconeseq.2ndbatch.merged.630.barcodes.tsv  \
  --dir10x  $dat_root_dir/matrix        \
  --refCellTypes  "Normal"     \
  --outdir  $out_dir     \
  --repoScripts  $repo_scripts_dir   \
  --repoXCL  $repo_xcltk_dir  \
  --cellAnno  $dat_root_dir/anno/sconeseq.2ndbatch.valid.630.cell_anno.2column.tsv  \
  --geneAnno  /groups/cgsd/xianjie/data/refapp/xclone/annotate_genes_hg38_update.txt  \
  --hgVersion  38   \
  --casperBAF  $dat_root_dir/anno   \
  --casperBAFSuffix  "snp.BAF.tsv"   \
  --casperGeneAnno  $dat_root_dir/anno/GBM_scone.genes.hg38.hgnc.rds  \
  --infercnvGeneAnno  /groups/cgsd/xianjie/data/refapp/xclone/hg38_gene_note_noheader_unique.txt  \
  --numbatGmap  /groups/cgsd/xianjie/data/refapp/eagle/Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz  \
  --numbatEagle  /home/xianjie/.anaconda3/envs/XCLBM/bin/eagle   \
  --numbatSNP  /groups/cgsd/xianjie/data/refapp/numbat/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz  \
  --numbatPanel  /groups/cgsd/xianjie/data/refapp/numbat/1000G_hg38  \
  --xcloneBAM  $dat_root_dir/bam/merged/sconeseq.2ndbatch.merged.bam  \
  --xcloneBarcodes  $dat_root_dir/bam/merged/sconeseq.2ndbatch.merged.630.barcodes.tsv  \
  --xcloneBamFA  /groups/cgsd/xianjie/data/refseq/refdata-cellranger-GRCh38-1.2.0/fasta/genome.fa  \
  --xcloneSangerFA  /groups/cgsd/xianjie/data/refapp/sanger_imputation/human_g1k_v37.fasta  \
  --xcloneGeneList  $repo_xcltk_dir/data/annotate_genes_hg38_update_20230126.txt  \
  --ncores  10

if [ -e "$out_dir/run.sh" ]; then
    chmod u+x $out_dir/run.sh
fi

