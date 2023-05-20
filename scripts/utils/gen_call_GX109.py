# gen_call_GX109.py - generate running scripts for CNV calling on GX109 dataset by each tool.


import getopt
import os
import sys
from gen_conf import VERSION


class Config:
    def __init__(self):
        self.sid = None        # sample ID

        self.bam_fn = None
        self.barcode_fn = None
        self.cell_tag = None

        self.dir_10x = None
        self.gene_is_row = None
 
        self.cell_anno_fn = None
        self.ref_cell_types = None

        self.gene_anno_fn = None
        self.hg_version = None

        self.casper_baf_dir = None
        self.casper_baf_suffix = None
        self.casper_gene_anno_fn = None

        self.infercnv_gene_anno_fn = None

        self.numbat_gmap_fn = None
        self.numbat_eagle_fn = None
        self.numbat_snp_fn = None
        self.numbat_panel_dir = None

        self.xclone_bam_fa_fn = None
        self.xclone_sanger_fa_fn = None
        self.xclone_gene_list_fn = None

        self.repo_scripts_dir = None
        self.repo_xcltk_dir = None
        self.out_dir = None
        self.n_cores = None

        # intermediate variables
        self.dir_casper = None
        self.dir_copykat = None
        self.dir_infercnv = None

        self.dir_numbat = None
        self.dir_numbat_pre = None

        self.dir_xclone = None
        self.dir_xclone_pre = None
        self.dir_xclone_pre_phase = None
        self.dir_xclone_post_phase = None
        self.dir_xclone_basefc = None

        self.pbs_ppn = 10
        self.pbs_mem = 200     # g
        self.pbs_time = 100    # hour


    def check_args(self):
        assert_n(self.sid)

        assert_e(self.bam_fn)
        assert_e(self.barcode_fn)
        assert_n(self.cell_tag)

        assert_e(self.dir_10x)
        if self.gene_is_row is None:
            self.gene_is_row = CONF_GENE_IS_ROW

        assert_e(self.cell_anno_fn)
        assert_n(self.ref_cell_types)
        
        assert_e(self.gene_anno_fn)
        assert_notnone(self.hg_version)
        if self.hg_version not in (19, 38):
            raise ValueError

        assert_e(self.casper_baf_dir)
        assert_n(self.casper_baf_suffix)
        assert_e(self.casper_gene_anno_fn)

        assert_e(self.infercnv_gene_anno_fn)

        assert_e(self.numbat_gmap_fn)
        assert_e(self.numbat_eagle_fn)
        assert_e(self.numbat_snp_fn)
        assert_e(self.numbat_panel_dir)

        assert_e(self.xclone_bam_fa_fn)
        assert_e(self.xclone_sanger_fa_fn)
        assert_e(self.xclone_gene_list_fn)

        assert_n(self.out_dir)
        if not os.path.exists(self.out_dir):
            os.mkdir(self.out_dir)

        assert_e(self.repo_scripts_dir)
        assert_e(self.repo_xcltk_dir)

        assert_notnone(self.n_cores)


def assert_e(path):
    if path is None or not os.path.exists(path):
        raise OSError


def assert_n(var):
    if var is None or not var:
        raise ValueError


def assert_notnone(var):
    if var is None:
        raise ValueError


def __pystr2bool(var):
    if var[0].lower() == "t":
        return True
    else:
        return False


def __pybool2rstr(var):
    var_str = str(var)
    if var_str == "True":
        return "TRUE"
    elif var_str == "False":
        return "FALSE"
    else:
        return ValueError


def __pylist2rstr(var):
    s = "c("
    s += ", ".join(['"%s"' % item for item in var])
    s += ")"
    return s


def __get_script_prefix(conf):
    return conf.sid + ".call"


def gen_casper_qsub(fn, conf):
    prefix = "casper_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
cp  %s/GX109/scRNA_CaSpER/casper.rna.R  $work_dir
cp  %s/GX109/scRNA_CaSpER/casper.rna.plot.R  $work_dir
''' % (conf.repo_scripts_dir, conf.repo_scripts_dir)

    out_dir = os.path.join(conf.dir_casper, "result")
    s += '''
#Rscript $work_dir/casper.rna.R  \\
#  <sample id>     \\
#  <matrix dir>   \\
#  <cell anno file>    \\
#  <control cell type> \\
#  <gene anno file>  \\
#  <hg version>   \\
#  <baf dir>     \\
#  <baf suffix>  \\
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.R \\
  %s  \\
  %s  \\
  %s  \\
  "%s"  \\
  %s  \\
  %d  \\
  %s    \\
  "%s"  \\
  %s
''' % (conf.sid, conf.dir_10x, conf.cell_anno_fn, 
        conf.ref_cell_types, conf.casper_gene_anno_fn, conf.hg_version,
        conf.casper_baf_dir, conf.casper_baf_suffix, out_dir)

    s += '''
#Rscript $work_dir/casper.rna.plot.R  \\
#  <sample id>  \\
#  <final chr mat> \\
#  <loh median data> \\
#  <out dir>

/usr/bin/time -v Rscript $work_dir/casper.rna.plot.R \\
  %s  \\
  %s/%s.final_chr_mat.rds  \\
  %s/%s.loh.median.filtered.data.rds  \\
  %s
''' % (conf.sid, 
        out_dir, conf.sid,
        out_dir, conf.sid,
        out_dir)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_copykat_qsub(fn, conf):
    prefix = "copykat_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
cp  %s/GX109/scRNA_copyKAT/copykat.rna.R  $work_dir
''' % (conf.repo_scripts_dir, )

    out_dir = os.path.join(conf.dir_copykat, "result")
    s += '''
#Rscript $work_dir/copykat.rna.R \\
#  <sample id>     \\
#  <matrix dir>   \\
#  <cell anno file>  \\
#  <control cell type> \\
#  <out dir>

/usr/bin/time -v Rscript $work_dir/copykat.rna.R \\
  %s  \\
  %s  \\
  %s  \\
  "%s"  \\
  %s 
''' % (conf.sid, conf.dir_10x, conf.cell_anno_fn, 
        conf.ref_cell_types, out_dir)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_infercnv_qsub(fn, conf):
    prefix = "infercnv_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLBM

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
cp  %s/GX109/scRNA_inferCNV/infercnv.rna.R  $work_dir
''' % (conf.repo_scripts_dir, )

    out_dir = os.path.join(conf.dir_infercnv, "result")
    s += '''
#Rscript $work_dir/infercnv.rna.R \\
#  <sample id>     \\
#  <matrix dir>   \\
#  <anno file>     \\
#  <ref cell type>  \\
#  <gene file>     \\
#  <out dir>

/usr/bin/time -v Rscript $work_dir/infercnv.rna.R \\
  %s  \\
  %s  \\
  %s  \\
  "%s"  \\
  %s  \\
  %s
''' % (conf.sid, conf.dir_10x, conf.cell_anno_fn, 
        conf.ref_cell_types, conf.infercnv_gene_anno_fn, out_dir)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def __get_numbat_pileup_dir(conf):
    return os.path.join(conf.dir_numbat_pre, "pileup")


def __get_numbat_reffilter_dir(conf):
    return os.path.join(conf.dir_numbat_pre, "ref_filter")


def __get_numbat_file_prefix(conf):
    return conf.sid + ".numbat"


def gen_numbat_preprocess_qsub(fn, conf):
    prefix = "preprocess_numbat_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
cp  %s/utils/pileup_and_phase.R  $work_dir
cp  %s/GX109/scRNA_numbat_preprocess/numbat.preprocess.R  $work_dir
''' % (conf.repo_scripts_dir, conf.repo_scripts_dir)

    out_dir = conf.dir_numbat_pre
    pileup_dir = __get_numbat_pileup_dir(conf)
    if not os.path.exists(pileup_dir):
        os.mkdir(pileup_dir)

    ref_filter_dir = __get_numbat_reffilter_dir(conf)
    if not os.path.exists(ref_filter_dir):
        os.mkdir(ref_filter_dir)

    s += '''
#usage: pileup_and_phase.R [-h] --label LABEL --samples SAMPLES --bams BAMS
#                          [--barcodes BARCODES] --gmap GMAP [--eagle EAGLE]
#                          --snpvcf SNPVCF --paneldir PANELDIR --outdir OUTDIR
#                          --ncores NCORES [--UMItag UMITAG]
#                          [--cellTAG CELLTAG] [--smartseq] [--bulk]
#
#Run SNP pileup and phasing with 1000G
#
#Arguments:
#  -h, --help           show this help message and exit
#  --label LABEL        Individual label
#  --samples SAMPLES    Sample names, comma delimited
#  --bams BAMS          BAM files, one per sample, comma delimited
#  --barcodes BARCODES  Cell barcode files, one per sample, comma delimited
#  --gmap GMAP          Path to genetic map provided by Eagle2 (e.g.
#                       Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz)
#  --eagle EAGLE        Path to Eagle2 binary file
#  --snpvcf SNPVCF      SNP VCF for pileup
#  --paneldir PANELDIR  Directory to phasing reference panel (BCF files)
#  --outdir OUTDIR      Output directory
#  --ncores NCORES      Number of cores

/usr/bin/time -v Rscript $work_dir/pileup_and_phase.R \\
  --label %s    \\
  --samples %s  \\
  --bams  %s  \\
  --barcodes  %s  \\
  --gmap   %s  \\
  --eagle  %s  \\
  --snpvcf  %s  \\
  --paneldir  %s  \\
  --outdir  %s  \\
  --ncores  %d 
''' % (conf.sid, conf.sid, 
        conf.bam_fn, conf.barcode_fn, 
        conf.numbat_gmap_fn, conf.numbat_eagle_fn, 
        conf.numbat_snp_fn, conf.numbat_panel_dir,
        pileup_dir, CONF_NUMBAT_NCORES)

    s += '''
#Rscript $work_dir/numbat.preprocess.R  \\
#  <allele file>       \\
#  <count matrix dir>  \\
#  <cell anno file>   \\
#  <ref cell type>    \\
#  <out dir>    \\
#  <out prefix>

/usr/bin/time -v Rscript $work_dir/numbat.preprocess.R  \\
  %s/%s_allele_counts.tsv.gz    \\
  %s  \\
  %s  \\
  "%s"      \\
  %s    \\
  %s
''' % (pileup_dir, conf.sid,
        conf.dir_10x, 
        conf.cell_anno_fn, 
        conf.ref_cell_types, 
        ref_filter_dir,
        __get_numbat_file_prefix(conf))

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_numbat_qsub(fn, conf):
    prefix = "%s_numbat" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate numbat

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
cp  %s/GX109/scRNA_numbat/numbat.rna.R  $work_dir
''' % (conf.repo_scripts_dir, )

    out_dir = os.path.join(conf.dir_numbat, "result")
    pileup_dir = __get_numbat_pileup_dir(conf)
    ref_filter_dir = __get_numbat_reffilter_dir(conf)
    fn_prefix = __get_numbat_file_prefix(conf)
    s += '''
#Rscript $work_dir/numbat.rna.R  \\
#  <count matrix>  \\
#  <ref expression>  \\
#  <allele dataframe>  \\
#  <out dir>   \\
#  <out prefix>  \\
#  <ncores>

/usr/bin/time -v Rscript $work_dir/numbat.rna.R \\
  %s/%s.ref_filtered.count.mtx.rds  \\
  %s/%s.ref.gene_by_celltype.mtx.rds  \\
  %s/%s.ref_filtered.allele.dataframe.rds  \\
  %s  \\
  %s  \\
  %d
''' % (ref_filter_dir, fn_prefix,
        ref_filter_dir, fn_prefix,
        ref_filter_dir, fn_prefix,
        out_dir,
        fn_prefix,
        CONF_NUMBAT_NCORES)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_xclone_pre_phase_qsub(fn, conf):
    prefix = "pre_phase_xclone_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLTK

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
%s/baf_pre_phase.sh  \\
  -N  %s  \\
  -s  %s  \\
  -b  %s  \\
  -F  %s  \\
  -O  %s  \\
  -g  %d  \\
  -C  %s  \\
  -u  UB  \\
  -p  %d 
''' % (conf.repo_xcltk_dir,
        conf.sid, conf.bam_fn,
        conf.barcode_fn, conf.xclone_sanger_fa_fn,
        conf.dir_xclone_pre_phase, conf.hg_version,
        conf.cell_tag, conf.n_cores)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_xclone_post_phase_qsub(fn, conf):
    prefix = "post_phase_xclone_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLTK

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
%s/baf_post_phase.sh  \\
  -N  %s  \\
  -s  %s  \\
  -b  %s  \\
  -v  %s/all.vcf.gz  \\
  -f  %s  \\
  -O  %s  \\
  -g  %d  \\
  -C  %s  \\
  -u  UB  \\
  -p  %d 
''' % (conf.repo_xcltk_dir,
        conf.sid, conf.bam_fn,
        conf.barcode_fn, conf.dir_xclone_phase,
        conf.xclone_bam_fa_fn,
        conf.dir_xclone_post_phase, conf.hg_version,
        conf.cell_tag, conf.n_cores)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def gen_xclone_basefc_qsub(fn, conf):
    prefix = "basefc_xclone_%s" % (conf.sid, )

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=%d,mem=%dg,walltime=%d:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, conf.pbs_ppn, conf.pbs_mem, conf.pbs_time, prefix, prefix)

    s += '''
source ~/.bashrc
conda activate XCLTK

# run `set` after `source` & `conda activate` as the source file has an unbound variable
set -eux

work_dir=`cd $(dirname $0) && pwd`
if [ -n "$PBS_O_WORKDIR" ]; then
    work_dir=$PBS_O_WORKDIR
fi
'''

    s += '''
xcltk basefc  \\
  -s  %s  \\
  -b  %s  \\
  -r  %s  \\
  -T  tsv  \\
  -O  %s  \\
  -p  %d  \\
  --cellTAG  %s  \\
  --UMItag  UB  \\
  --minLEN  30  \\
  --minMAPQ  20  \\
  --maxFLAG  4096
''' % (conf.bam_fn, conf.barcode_fn, 
        conf.xclone_gene_list_fn, conf.dir_xclone_basefc, 
        conf.n_cores, conf.cell_tag)

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)



def gen_xclone_qsub(fn, conf):
    return None


def gen_qsub(conf):
    func = "gen_qsub"

    qsub_list = []

    # run_state: whether the qsub script should be added to `run.sh`.
    for run_state, tool, gen_func, res_dir in zip(
        (True, True, True,
            True, False,
            True, False,
            True, False),
        ("casper", "copykat", "infercnv", 
            "numbat_preprocess", "numbat", 
            "xclone_pre_phase", "xclone_post_phase", 
            "xclone_basefc", "xclone"),
        (gen_casper_qsub, gen_copykat_qsub, gen_infercnv_qsub,
            gen_numbat_preprocess_qsub, gen_numbat_qsub,
            gen_xclone_pre_phase_qsub, gen_xclone_post_phase_qsub, 
            gen_xclone_basefc_qsub, gen_xclone_qsub),
        (conf.dir_casper, conf.dir_copykat, conf.dir_infercnv,
            conf.dir_numbat_pre, conf.dir_numbat,
            conf.dir_xclone_pre_phase, conf.dir_xclone_post_phase,
            conf.dir_xclone_basefc, conf.dir_xclone)):

        qsub_script = "%s.%s.qsub.sh" % (__get_script_prefix(conf), tool)
        qsub_script_path = os.path.join(res_dir, qsub_script)
        res_script = gen_func(qsub_script_path, conf)

        print("[I::%s] %s - %s" % (func, tool, qsub_script_path))
        if run_state:
            qsub_list.append((tool, res_dir, qsub_script))

    return(qsub_list)


def gen_run(conf, qsub_list):
    fn = os.path.join(conf.out_dir, "run.sh")

    s = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    for tool, run_dir, qsub_script in qsub_list:
        s += '''
cd %s
qsub %s
''' % (run_dir, qsub_script)

    s += '''
echo All Done!

'''

    with open(fn, "w") as fp:
        fp.write(s)

    return(fn)


def __safe_mkdir(dir_path):
    if not os.path.exists(dir_path):
        os.mkdir(dir_path)


def create_sub_res_dir(conf):
    conf.dir_casper = os.path.join(conf.out_dir, "%s_casper" % conf.sid)
    __safe_mkdir(conf.dir_casper)

    conf.dir_copykat = os.path.join(conf.out_dir, "%s_copykat" % conf.sid)
    __safe_mkdir(conf.dir_copykat)

    conf.dir_infercnv = os.path.join(conf.out_dir, "%s_infercnv" % conf.sid)
    __safe_mkdir(conf.dir_infercnv)

    conf.dir_numbat = os.path.join(conf.out_dir, "%s_numbat" % conf.sid)
    __safe_mkdir(conf.dir_numbat)

    conf.dir_numbat_pre = os.path.join(conf.out_dir, "%s_numbat_preprocess" % conf.sid)
    __safe_mkdir(conf.dir_numbat_pre)

    conf.dir_xclone = os.path.join(conf.out_dir, "%s_xclone" % conf.sid)
    __safe_mkdir(conf.dir_xclone)

    conf.dir_xclone_pre = os.path.join(conf.out_dir, "%s_xclone_preprocess" % conf.sid)
    __safe_mkdir(conf.dir_xclone_pre)

    conf.dir_xclone_pre_phase = os.path.join(conf.dir_xclone_pre, "pre_phase")
    __safe_mkdir(conf.dir_xclone_pre_phase)

    conf.dir_xclone_phase = os.path.join(conf.dir_xclone_pre, "phase")
    __safe_mkdir(conf.dir_xclone_phase)

    conf.dir_xclone_post_phase = os.path.join(conf.dir_xclone_pre, "post_phase")
    __safe_mkdir(conf.dir_xclone_post_phase)

    conf.dir_xclone_basefc = os.path.join(conf.dir_xclone_pre, "basefc")
    __safe_mkdir(conf.dir_xclone_basefc)


def usage(fp = sys.stderr):
    s =  "\n" 
    s += "Version: %s\n" % (VERSION, )
    s += "Usage: %s <options>\n" % (APP, )  
    s += "\n" 
    s += "Options:\n"
    s += "  --sid STR                Sample ID.\n"
    s += "  --bam FILE               BAM file.\n"
    s += "  --barcodes FILE          Barcode file.\n"
    s += "  --cellTAG STR            Cell barcode tag.\n"
    s += "  --dir10x DIR             Dir of 10x count matrix.\n"
    s += "  --refCellTypes STR       Reference cell types, semicolon separated.\n"
    s += "  --outdir DIR             Output dir.\n"
    s += "  --repoScripts DIR        Repo scripts dir.\n"
    s += "  --repoXCL DIR            Repo dir of xcltk.\n"
    s += "  --cellAnno FILE          Cell annotation file, 2 columns.\n"
    s += "  --geneAnno FILE          Gene annotation file.\n"
    s += "  --hgVersion INT          Version of genome, 19 or 38.\n"
    s += "  --geneIsRow BOOL         Whether row of count matrix is gene [%s]\n" % CONF_GENE_IS_ROW
    s += "  --casperBAF DIR          CaSpER BAF data dir.\n"
    s += "  --casperBAFSuffix STR    Suffix of the CaSpER BAF data file.\n"
    s += "  --casperGeneAnno FILE    CaSpER gene annotation file.\n"
    s += "  --infercnvGeneAnno FILE  InferCNV gene annotation file.\n"
    s += "  --numbatGmap FILE        Numbat gmap file.\n"
    s += "  --numbatEagle FILE       Numbat eagle path.\n"
    s += "  --numbatSNP FILE         Numbat SNP file.\n"
    s += "  --numbatPanel DIR        Numbat panel dir.\n"
    s += "  --xcloneBamFA FILE       XClone fasta file used for BAM alignment.\n"
    s += "  --xcloneSangerFA FILE    XClone fasta file used for Sanger fixref.\n"
    s += "  --xcloneGeneList FILE    XClone gene list file (TSV format).\n"
    s += "  --ncores INT             Number of cores.\n"
    s += "  --version                Print version and exit.\n"
    s += "  --help                   Print this message and exit.\n"
    s += "\n"

    fp.write(s)


def main():
    func = "main"

    if len(sys.argv) <= 1:
        usage(sys.stderr)
        sys.exit(1)

    conf = Config()
    opts, args = getopt.getopt(sys.argv[1:], "", [
        "sid=",
        "bam=", "barcodes=", "cellTAG=",
        "dir10x=", "geneIsRow=",
        "cellAnno=", "refCellTypes=",
        "geneAnno=", "hgVersion=",
        "outdir=",
        "repoScripts=", "repoXCL=",
        "casperBAF=", "casperBAFSuffix=", "casperGeneAnno=",
        "infercnvGeneAnno=",
        "numbatGmap=", "numbatEagle=", "numbatSNP=", "numbatPanel=",
        "xcloneBamFA=", "xcloneSangerFA=", "xcloneGeneList=",
        "ncores=",
        "version", "help"
    ])

    for op, val in opts:
        if len(op) > 2:
            op = op.lower()
        if op in   ("--sid"): conf.sid = val
        elif op in ("--bam"): conf.bam_fn = val
        elif op in ("--barcodes"): conf.barcode_fn = val
        elif op in ("--celltag"): conf.cell_tag = val
        elif op in ("--dir10x"): conf.dir_10x = val
        elif op in ("--geneisrow"): conf.gene_is_row = __pystr2bool(val)
        elif op in ("--cellanno"): conf.cell_anno_fn = val
        elif op in ("--refcelltypes"): conf.ref_cell_types = val
        elif op in ("--geneanno"): conf.gene_anno_fn = val
        elif op in ("--hgversion"): conf.hg_version = int(val)
        elif op in ("--outdir"): conf.out_dir = val
        elif op in ("--reposcripts"): conf.repo_scripts_dir = val
        elif op in ("--repoxcl"): conf.repo_xcltk_dir = val
        elif op in ("--casperbaf"): conf.casper_baf_dir = val
        elif op in ("--casperbafsuffix"): conf.casper_baf_suffix = val
        elif op in ("--caspergeneanno"): conf.casper_gene_anno_fn = val
        elif op in ("--infercnvgeneanno"): conf.infercnv_gene_anno_fn = val
        elif op in ("--numbatgmap"): conf.numbat_gmap_fn = val
        elif op in ("--numbateagle"): conf.numbat_eagle_fn = val
        elif op in ("--numbatsnp"): conf.numbat_snp_fn = val
        elif op in ("--numbatpanel"): conf.numbat_panel_dir = val
        elif op in ("--xclonebamfa"): conf.xclone_bam_fa_fn = val
        elif op in ("--xclonesangerfa"): conf.xclone_sanger_fa_fn = val
        elif op in ("--xclonegenelist"): conf.xclone_gene_list_fn = val
        elif op in ("--ncores"): conf.n_cores = int(val)
        elif op in ("--version"): sys.stderr.write("%s\n" % VERSION); sys.exit(1)
        elif op in ("--help"): usage(); sys.exit(1)
        else:
            sys.stderr.write("[E::%s] invalid option: '%s'.\n" % (func, op))
            return(-1)    

    conf.check_args()

    # create sub-dirs.
    create_sub_res_dir(conf)

    # generate qsub scripts
    qsub_list = gen_qsub(conf)

    # generate run scripts
    run_script = gen_run(conf, qsub_list)

    sys.stdout.write("[I::%s] All Done!\n" % func)


APP = "gen_call_GX109.py"

CONF_GENE_IS_ROW = True
CONF_NUMBAT_NCORES = 10
CONF_QSUB_MEM = 200


if __name__ == "__main__":
    main()

