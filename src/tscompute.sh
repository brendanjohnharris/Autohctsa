# The idea is that you'll have one or more time series sitting in the columns of a csv file
# This shell script will start matlab, calculated the features for each time series and save them to a csv file as well. By choice, hctsa will not preprocess the time series and all hctsa features will be calculated

#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -i infile -o outfile -h hctsadir"
   echo -e "\t-i Path to input time series file (.csv with time series along columns)"
   echo -e "\t-o Path to write features. (.csv, where the first column has feature names and subsequent columns have feature values)"
   echo -e "\t-h Path to a directory containing the hctsa source"
   exit 1
}

while getopts "i:o:h:" opt
do
   case "$opt" in
      i) infile="$OPTARG" ;;
      o) outfile="$OPTARG" ;;
      h) hctsadir="$OPTARG" ;;
      ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$infile" ] || [ -z "$outfile" ] || [ -z "$hctsadir" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script
matlab -nodisplay -singleCompThread -r "disp(pwd); tscompute('$infile', '$outfile', '$hctsa'); exit"