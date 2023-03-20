# Demo for getting BAF information using BAFExtract provided by CaSpER-For hg38 version
: ex: set ft=markdown ;:<<'```shell' #
2021-02-05 SET UP
Rongting Huang

## SET UP

```shell
export bam_file="/groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER/merged_bam/BCH869_merged.bam"
export BAFExtractCommand="/home/rthuang/Biosoftwares/BAFExtract/bin/BAFExtract"
export genome_list="/groups/cgsd/rthuang/data/CaSpER_data/hg19.list"
export sample_dir="/groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER/BAF_sample_bin"
export genome_fasta_pileup_dir="/groups/cgsd/rthuang/data/CaSpER_data/hg19/"
export output_baf_file="/groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER/BAF_out/BAF_BCH869"
:<<'```shell' # Ignore this line
```

## RUN BAFExtract command
```shell
samtools view ${bam_file} | ${BAFExtractCommand} -generate_compressed_pileup_per_SAM stdin ${genome_list} ${sample_dir} 50 0
${BAFExtractCommand} -get_SNVs_per_pileup ${genome_list} ${sample_dir} ${genome_fasta_pileup_dir} 20 4 0.1 ${output_baf_file}
exit $?
```
