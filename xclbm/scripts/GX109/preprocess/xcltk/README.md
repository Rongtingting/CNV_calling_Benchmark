
## XClone on GX109 dataset

### Aim
- run xcltk (v0.1.9) pipeline on GX109 dataset to generate BAF and RDR matrices

### Input
- GX109 dataset at `/groups/cgsd/yuanhua/samples/scRNA/GX109-T1c/`.

### Process
with xcltk v0.1.9

#### BAF
- run baf_pre.sh
- Sanger Imputation Server, phase only with EAGLE pipeline
- run baf_post.sh

#### RDR
- run rdr.sh

### Output
- at `/groups/cgsd/xianjie/xcltk-all/GX109/`.

