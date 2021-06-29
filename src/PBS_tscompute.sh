#!/bin/tcsh
#PBS -N autohctsa
#PBS -o output.txt
#PBS -j oe
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l walltime=01:00:00
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
module load Matlab2019b
cd "$PBS_O_WORKDIR"
touch "$PBS_JOBID"_log.txt
matlab -nodisplay -singleCompThread -r "disp(pwd); tscompute('xxinxx', 'xxoutxx', 'xxhctsaxx'); exit"
echo "Exiting..." >& "$PBS_JOBID"_log.txt
exit
