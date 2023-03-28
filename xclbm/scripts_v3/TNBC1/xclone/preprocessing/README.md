
## XClone on TNBC1 dataset 
### Aim
- run xcltk (v0.1.12) pipeline on TNBC1 dataset to generate BAF and RDR matrices

### Input
- TNBC1 dataset at `/groups/cgsd/rthuang/data/copyKAT/tnbc1` 
  (from biomed sever, /storage/yhhuang/research/mito/copyKAT/tnbc1)

### Process
Firstly, modify barcode file with modify_barcode.sh, adding suffix "-1" to each barcode
  so that the CB tag could be used instead of CR tag. Then, with xcltk v0.1.12,

#### BAF
- run baf_pre.sh 
- Sanger Imputation Server, phase only with EAGLE pipeline
- run baf_post.sh

#### RDR
- run rdr.sh

### Output
- at `/groups/cgsd/xianjie/kat_022621`.

### Note
- In baf_pre.sh, use xcltk v0.1.12 to genotype scRNA-seq bam file in a more proper 
  way (-d option for including duplicate reads and -u option for specifying UMI tag).

