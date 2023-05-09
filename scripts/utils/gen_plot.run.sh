#!/bin/bash
# gen_plot.run.sh


repo_scripts_dir=/home/xianjie/projects/CNV_calling_Benchmark/scripts
result_dir=/home/xianjie/debug/test-xclbm/plot
sid=GX109-T1c    # sample ID
sp=GX109         # script prefix
dat_root_dir=/home/xianjie/debug/test-xclbm/normal


if [ ! -e "$result_dir" ]; then
    mkdir $result_dir
fi


echo -e "\nGenerate ROC-plot scripts for gene scale.\n"
out_dir1=$result_dir/gene_roc
python  $repo_scripts_dir/utils/gen_plot.py  \
  --sid  $sid   \
  --sp  $sp        \
  --cnvScale  gene    \
  --datList  $dat_root_dir/gene_scale   \
  --metric  ROC        \
  --outdir  $out_dir1    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4     \
  --xyGain  0.7,0.25  \
  --xyLoss  0.7,0.25  \
  --xyLOH   0.666,0.2


echo -e "\nGenerate PRC-plot scripts for gene scale.\n"
out_dir2=$result_dir/gene_prc
python  $repo_scripts_dir/utils/gen_plot.py  \
  --sid  $sid   \
  --sp  $sp        \
  --cnvScale  gene    \
  --datList  $dat_root_dir/gene_scale   \
  --metric  PRC        \
  --outdir  $out_dir2    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4      \
  --xyGain  0.7,0.25  \
  --xyLoss  0.7,0.25  \
  --xyLOH   0.7,0.25


echo -e "\nGenerate ROC-plot scripts for arm scale.\n"
out_dir3=$result_dir/arm_roc
python  $repo_scripts_dir/utils/gen_plot.py  \
  --sid  $sid   \
  --sp  $sp        \
  --cnvScale  arm    \
  --datList  $dat_root_dir/arm_scale   \
  --metric  ROC        \
  --outdir  $out_dir3    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4      \
  --xyGain  0.7,0.25  \
  --xyLoss  0.7,0.25  \
  --xyLOH   0.666,0.2


echo -e "\nGenerate PRC-plot scripts for arm scale.\n"
out_dir4=$result_dir/arm_prc
python  $repo_scripts_dir/utils/gen_plot.py  \
  --sid  $sid   \
  --sp  $sp        \
  --cnvScale  arm    \
  --datList  $dat_root_dir/arm_scale   \
  --metric  PRC        \
  --outdir  $out_dir4    \
  --repoScripts  $repo_scripts_dir   \
  --plotDec  4      \
  --xyGain  0.7,0.25  \
  --xyLoss  0.7,0.25  \
  --xyLOH   0.7,0.25


sh_script=$result_dir/run.sh
echo "#!/bin/bash" > $sh_script
echo "" >> $sh_script
for out_dir in $out_dir1 $out_dir2 $out_dir3 $out_dir4; do
    qsub_script=`ls $out_dir/*.qsub.sh`
    if [ ! -e "$qsub_script" ]; then
        echo "Error: '$qsub_script' does not exist!"
        exit 1
    fi
    n_script=`echo $qsub_script | wc -w`
    if [ "$n_script" -ne 1 ]; then
        echo "Error: '$qsub_script' is invalid!"
        exit 1
    fi
    echo "cd $out_dir" >> $sh_script
    echo "qsub `basename $qsub_script`" >> $sh_script
    echo "" >> $sh_script
done

chmod u+x $sh_script

