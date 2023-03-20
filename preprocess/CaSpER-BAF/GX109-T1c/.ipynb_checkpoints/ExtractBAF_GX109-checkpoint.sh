# Demo for getting BAF information using BAFExtract provided by CaSpER-For hg38 version
: ex: set ft=markdown ;:<<'```shell' #
2021-02-03 SET UP
Rongting Huang

## SET UP

```shell
export bam_file="/groups/cgsd/yuanhua/CPOS_Data_20200408/10X5RNA/LeungSY_10X5RNA_SS-190409-04a/cellranger/GX109-T1c-5seq/count_GX109-T1c-5seq/outs/possorted_genome_bam.bam"
export BAFExtractCommand="/home/rthuang/Biosoftwares/BAFExtract/bin/BAFExtract"
export genome_list="/groups/cgsd/rthuang/data/CaSpER_data/hg38.list"
export sample_dir="/groups/cgsd/rthuang/Results/GX109/CaSpER/BAF_sample_bin"
export genome_fasta_pileup_dir="/groups/cgsd/rthuang/data/CaSpER_data/hg38/"
export output_baf_file="/groups/cgsd/rthuang/Results/GX109/CaSpER/BAF_out/BAF_GX109"
:<<'```shell' # Ignore this line
```

## RUN BAFExtract command
```shell
samtools view ${bam_file} | ${BAFExtractCommand} -generate_compressed_pileup_per_SAM stdin ${genome_list} ${sample_dir} 50 0
${BAFExtractCommand} -get_SNVs_per_pileup ${genome_list} ${sample_dir} ${genome_fasta_pileup_dir} 20 4 0.1 ${output_baf_file}
exit $?
```
