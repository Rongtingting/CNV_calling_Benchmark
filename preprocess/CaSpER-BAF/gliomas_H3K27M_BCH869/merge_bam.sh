# Demo for merging bam files of scRNA-seq data-preproecssing of BAF preparation of CaSpER
: ex: set ft=markdown ;:<<'```shell' #
2021-02-05 SET UP
Rongting Huang

## SET UP- to do

```shell
# cd /groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER
# mkdir merged_bam
# mkdir BAF_sample_bin
# Smkdir BAF_out
export bam_file_lst="/groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER/BCH869_bam.lst"
export sample_merged="/groups/cgsd/rthuang/Results/gliomas_H3K27M_BCH869/CaSpER/merged_bam/BCH869_merged.bam"
ls /groups/cgsd/xianjie/BCH869 | grep ".bam$" | awk '{print"/groups/cgsd/xianjie/BCH869/"$0}' > ${bam_file_lst}
:<<'```shell' # Ignore this line
```

## RUN BAFExtract command
```shell
bamtools merge -list ${bam_file_lst} -out ${sample_merged}
samtools index ${sample_merged}
exit $?
```
