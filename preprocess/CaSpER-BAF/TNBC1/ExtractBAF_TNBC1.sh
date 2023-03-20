# Getting BAF information using BAFExtract provided by CaSpER-For hg38 version
: ex: set ft=markdown ;:<<'```shell' #
2021-03-02 SET UP
Rongting Huang

## SET UP

```shell
export bam_file="/storage/yhhuang/research/mito/copyKAT/tnbc1/BAM_TNBC1.bam"
export BAFExtractCommand="/home/rthuang/ResearchProject/CaSpER/scr/BAFExtract/bin/BAFExtract"
export genome_list="/storage/yhhuang/users/rthuang/CaSpER_data/hg38.list"
export sample_dir="/storage/yhhuang/users/rthuang/Results/TNBC1/CaSpER/BAF_sample_bin"
export genome_fasta_pileup_dir="/storage/yhhuang/users/rthuang/CaSpER_data/hg38/"
export output_baf_file="/storage/yhhuang/users/rthuang/Results/TNBC1/CaSpER/BAF_out/BAF_TNBC1"
:<<'```shell' # Ignore this line
```

## RUN BAFExtract command
```shell
samtools view ${bam_file} | ${BAFExtractCommand} -generate_compressed_pileup_per_SAM stdin ${genome_list} ${sample_dir} 50 0
${BAFExtractCommand} -get_SNVs_per_pileup ${genome_list} ${sample_dir} ${genome_fasta_pileup_dir} 20 4 0.1 ${output_baf_file}
exit $?
```
