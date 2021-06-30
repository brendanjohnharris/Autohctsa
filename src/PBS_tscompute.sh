#!/bin/tcsh
#PBS -N autohctsa
#PBS -o output.txt
#PBS -j oe
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l walltime=01:00:00
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
cd "$PBS_O_WORKDIR"
echo "$PBS_O_WORKDIR"
touch "$PBS_JOBID"_log.txt
echo "Loading Matlab2019b...\n" >& "$PBS_JOBID"_log.txt
module load Matlab2019b
echo "Opening matlab...\n" >& "$PBS_JOBID"_log.txt
matlab -nodisplay -singleCompThread -r "disp(pwd); tscompute('xxinxx', 'xxoutxx', 'xxhctsaxx'); exit" | tee -a "$PBS_JOBID"_log.txt
echo "Exiting..." >& "$PBS_JOBID"_log.txt
exit
