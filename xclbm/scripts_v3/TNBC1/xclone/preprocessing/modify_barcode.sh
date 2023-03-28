#!/bin/bash

in=/groups/cgsd/rthuang/data/copyKAT/tnbc1/barcodes.lst
out=./barcodes.lst

cat $in | sed 's/$/-1/' > $out
