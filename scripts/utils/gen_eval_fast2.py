# gen_eval_fast2.py - generate running scripts (version fast2) for performance evaluation.


import getopt
import os
import sys
from gen_conf import VERSION


class Config:
    def __init__(self):
        self.sid = None        # sample ID
        self.cnv_scale = None  

        self.dat_list_dir = None
        self.xclone_dir = None

        self.gene_anno_fn = None
        self.repo_scripts_dir = None
        self.out_dir = None

        self.plot_dec = None

        # intermediate variables
        self.copy_gain_dir = None
        self.copy_loss_dir = None
        self.loh_dir = None


    def check_args(self):
        assert_n(self.sid)
        assert_n(self.cnv_scale)
        if self.cnv_scale not in ("gene", "arm"):
            raise ValueError

        assert_e(self.dat_list_dir)
        assert_e(self.xclone_dir)

        assert_e(self.gene_anno_fn)

        assert_n(self.out_dir)
        if not os.path.exists(self.out_dir):
            os.mkdir(self.out_dir)

        assert_e(self.repo_scripts_dir)

        if not self.plot_dec:
            self.plot_dec = CONF_PLOT_DEC


def assert_e(path):
    if path is None or not os.path.exists(path):
        raise OSError


def assert_n(var):
    if var is None or not var:
        raise ValueError


def __get_xclone_prob_dir(conf, cnv_type):
    if cnv_type == "copy_gain":
        return os.path.join(conf.xclone_dir, "prob_combine_copygain")
    elif cnv_type == "copy_loss":
        return os.path.join(conf.xclone_dir, "prob_combine_copyloss")
    elif cnv_type == "loh":
        return os.path.join(conf.xclone_dir, "prob_combine_loh")
    else:
        raise ValueError


def __get_script_prefix(conf):
    return conf.sid + ".eval.fast2"


def __get_roc(conf, cnv_type):
    cnv_scale = conf.cnv_scale
    dat_dir = os.path.join(conf.dat_list_dir, cnv_type, "result/s5_roc")
    dat_list_fn = os.path.join(dat_dir, 
        "%s.%s.%s_scale.roc.pre_plot_dat_list.list.rds" % (
        conf.sid, cnv_type, cnv_scale))
    assert_e(dat_list_fn)
    return dat_list_fn


def __get_prc(conf, cnv_type):
    cnv_scale = conf.cnv_scale
    dat_dir = os.path.join(conf.dat_list_dir, cnv_type, "result/s6_prc")
    dat_list_fn = os.path.join(dat_dir, 
        "%s.%s.%s_scale.prc.pre_plot_dat_list.list.rds" % (
        conf.sid, cnv_type, cnv_scale))
    assert_e(dat_list_fn)
    return dat_list_fn


def __get_cell_subset(conf, cnv_type):
    cnv_scale = conf.cnv_scale
    dat_dir = os.path.join(conf.dat_list_dir, cnv_type, "result/s3_annotate")
    dat_list_fn = os.path.join(dat_dir, 
        "%s.%s.%s_scale.subset.cells.df.tsv" % (
        conf.sid, cnv_type, cnv_scale))
    assert_e(dat_list_fn)
    return dat_list_fn


def __get_gene_subset(conf, cnv_type):
    cnv_scale = conf.cnv_scale
    dat_dir = os.path.join(conf.dat_list_dir, cnv_type, "result/s3_annotate")
    dat_list_fn = os.path.join(dat_dir, 
        "%s.%s.%s_scale.subset.genes.df.tsv" % (
        conf.sid, cnv_type, cnv_scale))
    assert_e(dat_list_fn)
    return dat_list_fn


def __get_truth(conf, cnv_type):
    cnv_scale = conf.cnv_scale
    dat_dir = os.path.join(conf.dat_list_dir, cnv_type, "result/s4_truth")
    dat_list_fn = os.path.join(dat_dir,
        "%s.%s.%s_scale.truth.cell_x_gene.binary.mtx.rds" % (
        conf.sid, cnv_type, cnv_scale))
    assert_e(dat_list_fn)
    return dat_list_fn


def __generate_r(fn, conf, cnv_type):
    if cnv_type not in ("copy_gain", "copy_loss", "loh"):
        raise ValueError
    cnv_scale = conf.cnv_scale

    s  = '''# This file was generated by "%s (v%s)."
# %s.R - benchmark on %s dataset

library(cardelino)
library(dplyr)
library(ggplot2)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]
setwd(work_dir)

source("benchmark.R")
source("main.R")
source("utils.R")
''' % (APP, VERSION, __get_script_prefix(conf), conf.sid)

    s += '''
sid <- "%s"
cnv_type <- "%s"    # could be "copy_gain", "copy_loss", or "loh".
cnv_scale <- "%s"        # could be "gene" or "arm".
''' % (conf.sid, cnv_type, cnv_scale)

    xclone_dir = __get_xclone_prob_dir(conf, cnv_type)
    roc_fn = __get_roc(conf, cnv_type)
    prc_fn = __get_prc(conf, cnv_type)
    s += '''
xclone_dir <- "%s"
roc_fn <- "%s"
prc_fn <- "%s"
metrics <- c("ROC", "PRC")
metric_fn <- c(roc_fn, prc_fn)
''' % (xclone_dir, roc_fn, prc_fn)

    cell_subset_fn = __get_cell_subset(conf, cnv_type)
    gene_subset_fn = __get_gene_subset(conf, cnv_type)
    truth_fn = __get_truth(conf, cnv_type)
    s += '''
gene_anno_fn <- "%s"
cell_subset_fn <- "%s"
gene_subset_fn <- "%s"
truth_fn <- "%s"
out_dir <- "result"
''' % (conf.gene_anno_fn, cell_subset_fn, gene_subset_fn, truth_fn)

    s += '''
bm_main_fast2(
  sid, cnv_type, cnv_scale,
  xclone_dir, metrics, metric_fn,
  gene_anno_fn,
  cell_subset_fn, gene_subset_fn, truth_fn, out_dir,
  overlap_mode = "customize", filter_func = NULL, max_n_cutoff = 1000,
  plot_dec = %d, plot_legend_xmin = 0.7, plot_legend_ymin = 0.25,
  plot_width = 6.5, plot_height = 5, plot_dpi = 600,
  verbose = TRUE, save_all = FALSE)

''' % (conf.plot_dec, )

    with open(fn, "w") as fp:
        fp.write(s)


def generate_r(conf):
    out_fn_list = []
    for cnv_type, out_dir in zip(("copy_gain", "copy_loss", "loh"),
        (conf.copy_gain_dir, conf.copy_loss_dir, conf.loh_dir)):
        out_fn = os.path.join(out_dir, "%s.R" % __get_script_prefix(conf))
        __generate_r(out_fn, conf, cnv_type)
        out_fn_list.append(out_fn)
    return out_fn_list


def __generate_qsub(fn, conf, cnv_type, r_script):
    if cnv_type not in ("copy_gain", "copy_loss", "loh"):
        raise ValueError
    cnv_scale = conf.cnv_scale
    prefix = "%s_%s_%s" % (cnv_scale, cnv_type, conf.sid)

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=5,mem=200g,walltime=100:00:00
#PBS -o %s.out
#PBS -e %s.err
''' % (prefix, prefix, prefix)

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
scripts_dir=%s
cp  $scripts_dir/evaluate/benchmark.R  $work_dir
cp  $scripts_dir/evaluate/main.R  $work_dir
cp  $scripts_dir/evaluate/utils.R  $work_dir
''' % (conf.repo_scripts_dir, )

    s += '''
Rscript  $work_dir/%s  $work_dir
''' % (r_script, )

    s += '''
set +ux
conda deactivate
echo "All Done!"

'''
    
    with open(fn, "w") as fp:
        fp.write(s)


def generate_qsub(conf):
    out_fn_list = []
    for cnv_type, out_dir in zip(("copy_gain", "copy_loss", "loh"),
        (conf.copy_gain_dir, conf.copy_loss_dir, conf.loh_dir)):
        out_fn = os.path.join(out_dir, "%s.qsub.sh" % __get_script_prefix(conf))
        r_script = "%s.R" %  __get_script_prefix(conf)
        __generate_qsub(out_fn, conf, cnv_type, r_script)
        out_fn_list.append(out_fn)
    return out_fn_list


def generate_run(conf):
    out_fn = os.path.join(conf.out_dir, "run.sh")

    s = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    for run_dir in (conf.copy_gain_dir, conf.copy_loss_dir, conf.loh_dir):
        s += '''
cd %s
qsub %s.qsub.sh
''' % (run_dir, __get_script_prefix(conf))

    s += '''
echo All Done!

'''

    with open(out_fn, "w") as fp:
        fp.write(s)
  
    return out_fn


def usage(fp = sys.stderr):
    s =  "\n" 
    s += "Version: %s\n" % (VERSION, )
    s += "Usage: %s <options>\n" % (APP, )  
    s += "\n" 
    s += "Options:\n"
    s += "  --sid STR              Sample ID.\n"
    s += "  --cnvScale STR         CNV scale, gene or arm.\n"
    s += "  --outdir DIR           Output dir.\n"
    s += "  --datList DIR          Dir containing previous data list.\n"
    s += "  --xclone DIR           XClone dir.\n"
    s += "  --geneAnno FILE        Gene annotation file.\n"
    s += "  --repoScripts DIR      Repo scripts dir.\n"
    s += "  --plotDec INT          Decimal in plots [%d]\n" % CONF_PLOT_DEC
    s += "  --version              Print version and exit.\n"
    s += "  --help                 Print this message and exit.\n"
    s += "\n"

    fp.write(s)


def main():
    func = "main"

    if len(sys.argv) <= 1:
        usage(sys.stderr)
        sys.exit(1)

    conf = Config()
    opts, args = getopt.getopt(sys.argv[1:], "", [
        "sid=", "cnvScale=",
        "outdir=",
        "datList=", "xclone=", 
        "geneAnno=", 
        "repoScripts=",
        "plotDec=",
        "version", "help"
    ])

    for op, val in opts:
        if len(op) > 2:
            op = op.lower()
        if op in   ("--sid"): conf.sid = val
        elif op in ("--cnvscale"): conf.cnv_scale = val
        elif op in ("--outdir"): conf.out_dir = val
        elif op in ("--datlist"): conf.dat_list_dir = val
        elif op in ("--xclone"): conf.xclone_dir = val
        elif op in ("--geneanno"): conf.gene_anno_fn = val
        elif op in ("--reposcripts"): conf.repo_scripts_dir = val
        elif op in ("--plotdec"): conf.plot_dec = int(val)
        elif op in ("--version"): sys.stderr.write("%s\n" % VERSION); sys.exit(1)
        elif op in ("--help"): usage(); sys.exit(1)
        else:
            sys.stderr.write("[E::%s] invalid option: '%s'.\n" % (func, op))
            return(-1)    

    conf.check_args()

    # create sub dirs.
    conf.copy_gain_dir = os.path.join(conf.out_dir, "copy_gain")
    if not os.path.exists(conf.copy_gain_dir):
        os.mkdir(conf.copy_gain_dir)

    conf.copy_loss_dir = os.path.join(conf.out_dir, "copy_loss")
    if not os.path.exists(conf.copy_loss_dir):
        os.mkdir(conf.copy_loss_dir)

    conf.loh_dir = os.path.join(conf.out_dir, "loh")
    if not os.path.exists(conf.loh_dir):
        os.mkdir(conf.loh_dir)

    # generate R scripts
    r_scripts = generate_r(conf)
    print("R scripts: %s\n" % str(r_scripts))

    # generate qsub scripts
    qsub_scripts = generate_qsub(conf)
    print("qsub scripts: %s\n" % str(qsub_scripts))

    # generate run shell scripts
    run_script = generate_run(conf)
    print("run script: %s\n" % (run_script, ))

    sys.stdout.write("[I::%s] All Done!\n" % func)


APP = "gen_eval_fast2.py"

CONF_PLOT_DEC = 3


if __name__ == "__main__":
    main()

