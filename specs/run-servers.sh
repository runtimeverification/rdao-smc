#!/bin/sh

###    Part of rdao-smc: A probabilistic rewriting model of RANDAO schemes
###
###    Musab A. Alturki
###    September 2018
###    Runtime Verifcation Inc.
###
###
###    run-servers.sh: Run the desired numner of LOCAL servers
###
###    Usage example:
###        ./run-servers 2
###

###
### You will probably want to configure the following based on your environment
###

### Set the location of the PVeStA Server jar file here
export PVESTA_BIN="/Users/musab/Documents/_PVeStA-temp"

### Set the starting port number 
### (Note: port numbers lower than 1024 are usually reserved)
export PVESTA_PORT="49046"


###
# Checks whether the number of servers is supplied as an argument
if [ -z "${1}" ] 
    then 
    echo "Missing number of servers to run."
    echo "Usage: run-servers.sh N"
else
    PORT=$PVESTA_PORT
    for (( c = 1; c <= ${1}; c++ ))
      do
      OFILE="server_$c.out"
      echo "Running server $c at port $PORT..."
      java -jar $PVESTA_BIN/pvesta-server.jar $PORT > $OFILE &
      PORT=`expr $PORT + 1` 
    done
fi
