# sam_filter_cells - filter reads of specific cells from sam/bam/cram file.
# samtools does not support this function yet (2023-05-11)


import getopt
import os
import pysam
import sys


def assert_e(path):
    if path is None or not os.path.exists(path):
        raise OSError


def assert_n(var):
    if var is None or not var:
        raise ValueError


def usage(fp = sys.stderr):
    s =  "\n" 
    s += "Version: %s\n" % (VERSION, )
    s += "Usage: %s <options>\n" % (APP, )  
    s += "\n" 
    s += "Options:\n"
    s += "  --inBAM FILE           Input BAM file.\n"
    s += "  --cellTAG STR          Cell barcode tag.\n"
    s += "  --barcodes FILE        Barcodes to be filtered.\n"
    s += "  --outBAM FILE          Output BAM file.\n"
    s += "  --filteredBAM FILE     BAM file containing filtered reads.\n"
    s += "  --version              Print version and exit.\n"
    s += "  --help                 Print this message and exit.\n"
    s += "\n"

    fp.write(s)


def main():
    func = "main"

    if len(sys.argv) <= 1:
        usage(sys.stderr)
        sys.exit(1)

    in_bam_fn = None
    cell_tag = barcode_fn = None
    out_bam_fn = None
    flt_bam_fn = None

    opts, args = getopt.getopt(sys.argv[1:], "", [
        "inBAM=",
        "cellTAG=", "barcodes=",
        "outBAM=",
        "filteredBAM=",
        "version", "help"
    ])

    for op, val in opts:
        if len(op) > 2:
            op = op.lower()
        if op in   ("--inbam"): in_bam_fn = val
        elif op in ("--celltag"): cell_tag = val
        elif op in ("--barcodes"): barcode_fn = val
        elif op in ("--outbam"): out_bam_fn = val
        elif op in ("--filteredbam"): flt_bam_fn = val
        elif op in ("--version"): sys.stderr.write("%s\n" % VERSION); sys.exit(1)
        elif op in ("--help"): usage(); sys.exit(1)
        else:
            sys.stderr.write("[E::%s] invalid option: '%s'.\n" % (func, op))
            return(-1)    

    assert_e(in_bam_fn)
    assert_n(cell_tag)
    assert_e(barcode_fn)
    assert_n(out_bam_fn)

    barcodes = set()
    with open(barcode_fn, "r") as fp:
        for cb in fp:
            barcodes.add(cb.strip())
    
    in_sam = pysam.AlignmentFile(in_bam_fn, "rb")
    out_sam = pysam.AlignmentFile(out_bam_fn, "wb", template = in_sam)
    flt_sam = pysam.AlignmentFile(flt_bam_fn, "wb", template = in_sam)

    n_total = n_filter = 0
    for read in in_sam.fetch():
        n_total += 1
        if read.has_tag(cell_tag):
            cb = read.get_tag(cell_tag)
            if cb in barcodes:
                n_filter += 1
                flt_sam.write(read)
                continue
        out_sam.write(read)

    in_sam.close()
    out_sam.close()
    flt_sam.close()

    print("[I::%s] #total_read = %d; #filtered_read = %d." % (
            func, n_total, n_filter))
    

APP = "sam_filter_cells.py"
VERSION = "0.0.1"


if __name__ == "__main__":
    main()

