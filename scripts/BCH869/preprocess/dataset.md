
## BCH869
steps of processing BCH869 dataset.

### Dataset preprocessing
BCH869 is a SMART-seq2 scRNA-seq dataset. 
- Fastq files: 1920 fastq files, ~68G in total.
  (stored at `/storage/yhhuang/frozenDat/gliomasH3K27M/BCH869/fastq`)
- The fastq files were aligned to hg19 (CellRanger refdata hg19-3.0.0) with STAR 2.7.7a. 
  The cmdline is `dataset/star_aln.sh`.
- The sam files were converted to bam files before being sorted with samtools v1.10.
  The cmdline is `dataset/sam2bam.sh`.

### Summary of dataset
The bam files are stored at `/groups/cgsd/xianjie/BCH869`.
- bam files: 960 bam files, ~48G

