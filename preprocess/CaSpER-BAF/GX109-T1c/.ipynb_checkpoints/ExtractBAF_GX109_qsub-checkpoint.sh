#!/bin/bash
# Author:Rongting 
# Date:2021-02-03
# contact:rthuang@connect.hku.hk
# =================================================================================
# Rongting Huang demo for PBS job submitting(Multi Proecessor Job)-CPOS Server
# =================================================================================
# declare a name for this job to be sample_job****
#PBS -N BAFExtract_GX109_hg38
# request the queue (enter the possible names, if omitted, serial is the default)
# you can use small, small_ext, medium, medium_ext, large, legacy and test for -q.
# For cpos server now, we set the cgsd queue
#PBS -q cgsd
# request a total of 20 processors for this job (1 nodes and 20 processors per node)
#PBS -l nodes=1:ppn=20
#PBS -l mem=200g
#PBS -l walltime=20:00:00
# mail is sent to you when the job starts and when it terminates or aborts
#PBS -m bea
# specify your email address
#PBS -M rthuang@connect.hku.hk
# Join option that merges the standard error stream with the standard output stream of the job.
#PBS -j oe
# The path and file name for standard output.****
#PBS -o /groups/cgsd/rthuang/Results/GX109/CaSpER-log/GX109_EXtractBAF_hg38_out_20210203.log
# The path and file name for standard error.****
#PBS -e /groups/cgsd/rthuang/Results/GX109/CaSpER-log/GX109_EXtractBAF_hg38_out_20210203.err
# =================================================================================
# By default, PBS scripts execute in your home directory, not the 
# directory from which they were submitted. The following line 
# places you in the directory from which the job was submitted.
PBS_O_WORKDIR="/home/rthuang/ResearchProject/CaSpER"
cd $PBS_O_WORKDIR
echo "Rongting's Notes: Now, you are in ${PBS_O_WORKDIR}"
# if you want to activate the specific conda env, then conda activate the one you want.
source ~/.bashrc
conda activate chisel
echo "Rongting's Notes: activate your conda env chisel"
# =================================================================================**
# run the program****
echo "Rongting's Notes: start the Project!--CaSpER"
## sh /home/rthuang/data/chisel/GX109/chisel_GX109.sh(PREVIOUS COMMAND)
sh /home/rthuang/ResearchProject/CaSpER/src/GX109/ExtractBAF_GX109.sh
echo "Rongting's Notes: stop the Project--CaSpER"
# =================================================================================**
conda deactivate
echo "Rongting's Notes: deactivate the conda env chisel"
exit