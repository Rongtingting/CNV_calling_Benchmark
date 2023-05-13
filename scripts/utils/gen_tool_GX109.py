# gen_tool_GX109.py - generate running scripts for preprocessing GX109 dataset by each tool


import getopt
import os
import sys
from gen_conf import VERSION


class Config:
    def __init__(self):
        self.sid = None        # sample ID
        self.sp = None         # script prefix

        self.bam_fn = None
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

        self.repo_scripts_dir = None
        self.out_dir = None


    def check_args(self):
        assert_n(self.sid)
        assert_n(self.sp)

        assert_e(self.bam_fn)
        assert_n(self.cell_tag)

        assert_e(self.dir_10x)
        if self.gene_is_row is None:
            self.gene_is_row = CONF_GENE_IS_ROW

        assert_e(self.cell_anno_fn)
        assert_n(self.target_cell_types)
        self.target_cell_types = self.target_cell_types.split(";")
        
        if (self.sc_N is None) == (self.sc_perc is None):
            raise ValueError
        if self.seed is None:
            self.seed = CONF_SEED
        if self.sort_cells is None:
            self.sort_cells = CONF_SORT_CELLS

        assert_e(self.gene_anno_fn)

        assert_n(self.out_dir)
        if not os.path.exists(self.out_dir):
            os.mkdir(self.out_dir)

        assert_e(self.repo_scripts_dir)


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


def __get_out_prefix(conf):
    return conf.sp + ".simu"


def generate_r(fn, conf):
    s  = '''# This file was generated by "%s (v%s)."
# %s.R - data simulation.

library(Matrix)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]
setwd(work_dir)

source("main.R")
source("simulation.R")
''' % (APP, VERSION, __get_out_prefix(conf))

    s += '''
sid <- "%s"

dir_10x <- "%s"
gene_is_row <- %s
''' % (conf.sid, conf.dir_10x, __pybool2rstr(conf.gene_is_row))

    s += '''
cell_anno_fn <- "%s"
target_cell_types <- %s
N <- %s
perc <- %s
seed <- %d
sort_cells <- %s
''' % (conf.cell_anno_fn, 
         __pylist2rstr(conf.target_cell_types),
        "NULL" if conf.sc_N is None else str(conf.sc_N),
        "NULL" if conf.sc_perc is None else str(conf.sc_perc),
        conf.seed,
        __pybool2rstr(conf.sort_cells))

    s += '''
gene_anno_fn <- "%s"
''' % (conf.gene_anno_fn, )

    s += '''
out_dir <- "%s"
''' % (conf.out_dir, )

    s += '''
simu_main(sid = sid, 
  dir_10x = dir_10x, gene_is_row = gene_is_row,
  cell_anno_fn = cell_anno_fn, target_cell_types = target_cell_types,
  N = N, perc = perc, seed = seed, sort_cells = sort_cells,
  gene_anno_fn = gene_anno_fn,
  out_dir = out_dir)

'''

    with open(fn, "w") as fp:
        fp.write(s)


def generate_qsub(fn, conf, r_script):
    prefix = "N%s_perc%s_%s" % (conf.sc_N, conf.sc_perc, conf.sid)

    s  = '''#!/bin/bash
# This file was generated by "%s (v%s)."
''' % (APP, VERSION)

    s += '''#PBS -N %s
#PBS -q cgsd
#PBS -l nodes=1:ppn=10,mem=200g,walltime=100:00:00
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
# sampling cells and count matrix
scripts_dir=%s
cp  $scripts_dir/simulate/main.R  $work_dir
cp  $scripts_dir/simulate/simulation.R  $work_dir
''' % (conf.repo_scripts_dir, )

    s += '''
Rscript  $work_dir/%s  $work_dir
''' % (r_script, )

    bam_dir = os.path.join(conf.out_dir, "bam")
    s += '''
# filter BAM
res_dir=$work_dir

bam_dir=$res_dir/bam
if [ ! -e "$bam_dir" ]; then
    mkdir -p $bam_dir
fi

out_bam_fn=$bam_dir/%s.out.bam
flt_bam_fn=$bam_dir/%s.filtered.bam

python  $scripts_dir/simulate/sam_filter_cells.py  \\
  --inBAM  %s  \\
  --cellTAG  %s  \\
  --barcodes  $res_dir/barcodes/nonsampled_target_cells.tsv  \\
  --outBAM  $out_bam_fn  \\
  --filteredBAM  $flt_bam_fn 

if [ $? -eq 0 ]; then
    if [ -e "$out_bam_fn" ]; then
        samtools index $out_bam_fn
    fi
    if [ -e "$flt_bam_fn" ]; then
        samtools index $flt_bam_fn
    fi
else
    echo "Error: filter BAM file failed."
fi

''' % (conf.sp, conf.sp, conf.bam_fn, conf.cell_tag)
    
    with open(fn, "w") as fp:
        fp.write(s)


def usage(fp = sys.stderr):
    s =  "\n" 
    s += "Version: %s\n" % (VERSION, )
    s += "Usage: %s <options>\n" % (APP, )  
    s += "\n" 
    s += "Options:\n"
    s += "  --sid STR              Sample ID.\n"
    s += "  --sp STR               Script prefix.\n"
    s += "  --bam FILE             BAM file.\n"
    s += "  --cellTAG STR          Cell barcode tag.\n"
    s += "  --dir10x DIR           Dir of 10x count matrix.\n"
    s += "  --targetCellTypes STR  Cell types to be sampled, semicolon separated.\n"
    s += "  --N INT                Number of cells (of --targetCellTypes) to be sampled.\n"
    s += "  --perc FLOAT           Percentage of cells (of --targetCellTypes) to be sampled.\n"
    s += "  --outdir DIR           Output dir.\n"
    s += "  --repoScripts DIR      Repo scripts dir.\n"
    s += "  --cellAnno FILE        Cell annotation file, 2 columns.\n"
    s += "  --geneAnno FILE        Gene annotation file, 2 columns.\n"
    s += "  --geneIsRow BOOL       Whether row of count matrix is gene [%s]\n" % CONF_GENE_IS_ROW
    s += "  --sortCells BOOL       Whether to sort output cell barcodes [%s]\n" % CONF_SORT_CELLS
    s += "  --seed INT             Random seed [%d]\n" % CONF_SEED
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
        "sid=", "sp=",
        "bam=", "cellTAG=",
        "dir10x=", "geneIsRow=",
        "cellAnno=", "targetCellTypes=",
        "N=", "perc=",
        "seed=", "sortCells=",
        "geneAnno=",
        "outdir=",
        "repoScripts=",
        "version", "help"
    ])

    for op, val in opts:
        if len(op) > 2:
            op = op.lower()
        if op in   ("--sid"): conf.sid = val
        elif op in ("--sp"): conf.sp = val
        elif op in ("--bam"): conf.bam_fn = val
        elif op in ("--celltag"): conf.cell_tag = val
        elif op in ("--dir10x"): conf.dir_10x = val
        elif op in ("--geneisrow"): conf.gene_is_row = __pystr2bool(val)
        elif op in ("--cellanno"): conf.cell_anno_fn = val
        elif op in ("--targetcelltypes"): conf.target_cell_types = val
        elif op in ("--n"): conf.sc_N = int(val)
        elif op in ("--perc"): conf.sc_perc = float(val)
        elif op in ("--seed"): conf.seed = int(val)
        elif op in ("--sortcells"): conf.sort_cells = __pystr2bool(val)
        elif op in ("--geneanno"): conf.gene_anno_fn = val
        elif op in ("--outdir"): conf.out_dir = val
        elif op in ("--reposcripts"): conf.repo_scripts_dir = val
        elif op in ("--version"): sys.stderr.write("%s\n" % VERSION); sys.exit(1)
        elif op in ("--help"): usage(); sys.exit(1)
        else:
            sys.stderr.write("[E::%s] invalid option: '%s'.\n" % (func, op))
            return(-1)    

    conf.check_args()

    # generate R scripts
    r_script = "%s.R" % __get_out_prefix(conf)
    r_script_path = os.path.join(conf.out_dir, r_script)
    generate_r(r_script_path, conf)
    print("R scripts: %s\n" % str(r_script_path))

    # generate qsub scripts
    qsub_script = "%s.qsub.sh" % __get_out_prefix(conf)
    qsub_script_path = os.path.join(conf.out_dir, qsub_script)
    generate_qsub(qsub_script_path, conf, r_script)
    print("qsub scripts: %s\n" % str(qsub_script_path))

    sys.stdout.write("[I::%s] All Done!\n" % func)


APP = "gen_tool_GX109.py"

CONF_GENE_IS_ROW = True
CONF_SEED = 123
CONF_SORT_CELLS = True


if __name__ == "__main__":
    main()

