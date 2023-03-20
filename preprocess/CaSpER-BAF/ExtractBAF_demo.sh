# Demo for getting BAF information using BAFExtract provided by CaSpER-For hg38 version
: ex: set ft=markdown ;:<<'```shell' #
2021-02-03 SET UP
Rongting Huang

## SET UP

```shell
export bam_file="/storage/yhhuang/users/rthuang/CaSpER_data/examples/SRR1295366.sorted.bam"
export BAFExtractCommand="/home/rthuang/Biosoftwares/BAFExtract/bin/BAFExtract"
export genome_list="/groups/cgsd/rthuang/data/CaSpER_data/hg38.list"
export sample_dir="/storage/yhhuang/users/rthuang/CaSpER_data/example_bin_test1"
export genome_fasta_pileup_dir="/groups/cgsd/rthuang/data/CaSpER_data/hg38/"
export output_baf_file="/storage/yhhuang/users/rthuang/CaSpER_data/example_BAF_out/baf_test1"
:<<'```shell' # Ignore this line
```

## RUN BAFExtract command
```shell
samtools view ${bam_file} | ${BAFExtractCommand} -generate_compressed_pileup_per_SAM stdin ${genome_list} ${sample_dir} 50 0
${BAFExtractCommand} -get_SNVs_per_pileup ${genome_list} ${sample_dir} ${genome_fasta_pileup_dir} 20 4 0.1 ${output_baf_file}
exit $?
```
