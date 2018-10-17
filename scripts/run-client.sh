#!/bin/sh

###    Part of rdao-smc: A probabilistic rewriting model of RANDAO schemes
###
###    Musab A. Alturki
###    September 2018
###    Runtime Verifcation Inc.
###
###
###    run-client.sh: Runs the verification tasks
###
###    Usage example:
###        ./run-client 2 model.maude formula.quatex
###

###
### You will probably want to configure the following based on your environment
###

### Set the location of the PVeStA Server jar file here
export PVESTA_BIN="/Users/musab/Documents/_PVeStA-temp"

### Set the filename prefix where the servers are to be found
export SL_FILE_PRE="portlist"

### You can specify how many times the same verification task is repeated (default is 1)
export TRIALS=1


###
# Checks whether all the required arguments are supplied
if [ -z "${1}" ] 
    then 
    echo "Missing number of servers to use."
    echo "Usage: run-client.sh <N> <maude_model_file> <quatex_formula_file>"
else if [ -z "${2}" ] 
    then 
    echo "Missing Maude model file."
    echo "Usage: run-client.sh <N> <maude_model_file> <quatex_formula_file>"
else if [ -z "${3}" ] 
    then 
    echo "Missing QuaTEx formula file."
    echo "Usage: run-client.sh <N> <maude_model_file> <quatex_formula_file>"
else
    trials=$TRIALS
    for (( c = 1; c <= $trials; c++ ))
      do
      echo "##### Running trial $c..."
      java -jar $PVESTA_BIN/pvesta-client.jar -l $SL_FILE_PRE${1} -m $2 -f $3 -a 0.05 -d1 0.05
      sleep 1
      rm _*
    done
fi fi fi
