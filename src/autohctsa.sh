#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i infile -o outfile -s hostname"
   echo -e "\t-i Local path to input time series file (.csv with time series along columns)"
   echo -e "\t-o ABSOLUTE remote path to write features (with leading /)"
   echo -e "\t-s User and host name (e.g. bhar9988@headnode.physics.usyd.edu.au)"
   exit 1
}

while getopts "i:o:s:" opt
do
   case "$opt" in
      i) infile="$OPTARG" ;;
      o) outfile="$OPTARG" ;;
      s) hostname="$OPTARG" ;;
      ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$infile" ] || [ -z "$outfile" ] || [ -z "$hostname" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script
basein=$(basename $infile)
dirout=$(dirname $outfile)

# Copy over important files
ssh $hostname "mkdir -p dirout"
scp "$infile" "${hostname}:$dirout/$basein"
scp "$(dirname $0)/tscompute.sh" "${hostname}:$dirout/tscompute.sh"
scp "$(dirname $0)/PBS_tscompute.sh" "${hostname}:$dirout/PBS_tscompute.sh"
scp "$(dirname $0)/tscompute.m" "${hostname}:$dirout/tscompute.m"

# Create job script and submit
ssh $hostname "cd $dirout/; sed -e "s+xxinxx+$dirout/$basein+g" -e "s+xxoutxx+$outfile+g" -e "s+xxhctsaxx+~/hctsa+g" ./PBS_tscompute.sh > ./PBS_$basein.sh"
ssh $hostname "cd $dirout/; /usr/physics/pbspro/bin/qsub PBS_$basein.sh;"
