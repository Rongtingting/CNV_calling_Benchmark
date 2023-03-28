#!/usr/bin/env python

import sys

def chrom_s2i(chrom):
  global CHROM
  global CHROM_MAX
  if chrom.startswith("chr"):
    chrom = chrom[3:]
  if chrom in CHROM:
    return CHROM[chrom]
  else:
    CHROM_MAX += 1
    CHROM[chrom] = CHROM_MAX
    return CHROM_MAX

def sort_gene(gene1, gene2):
  gene_name1, chrom1, start1, end1 = gene1[:4]
  gene_name2, chrom2, start2, end2 = gene2[:4]
  chrom1 = chrom_s2i(chrom1)
  chrom2 = chrom_s2i(chrom2)
  if chrom1 != chrom2:
    return chrom1 - chrom2
  elif start1 != start2:
    return start1 - start2
  elif end1 != end2:
    return end1 - end2
  else:
    return cmp(gene_name1, gene_name2)

if len(sys.argv) < 3:
  print("Usage: %s <in gtf> <out tsv>" % sys.argv[0])
  sys.exit(1)

in_fn = sys.argv[1]
out_fn = sys.argv[2]

CHROM = {str(i):i for i in range(1, 23)}
CHROM["X"] = 23
CHROM["Y"] = 24
CHROM["M"] = 25
CHROM["MT"] = 26
CHROM_MAX = 26

records = []
genes = set()
with open(in_fn, "r") as fp:
  for line in fp:
    if line[0] == '#':
      continue
    parts = line.strip().split("\t")
    chrom, _type, start, end = parts[0], parts[2], int(parts[3]), int(parts[4])
    if _type != "gene":
      continue
    attrs = parts[8].split(" ")
    attrs = [val.strip().strip(';"') for val in attrs if val.replace(" ", "")]
    for idx, val in enumerate(attrs):
      if val == "gene_name":
        break
    if idx >= len(attrs) - 1:
      print("Warning: skip gene '%s:%d-%d'" % (chrom, start, end))
      continue
    gene_name = attrs[idx + 1]
    if gene_name in genes:
      print("Warning: skip duplicate gene '%s'" % gene_name)
      continue
    genes.add(gene_name)
    records.append((gene_name, chrom, start, end))

with open(out_fn, "w") as fp:
  records = sorted(records, cmp = sort_gene)
  for rec in records:
    s = "\t".join([str(v) for v in rec]) + "\n"
    fp.write(s)

print("All Done!")

