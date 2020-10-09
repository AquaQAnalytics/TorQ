#!/bin/bash

# Parse command line arguments -d:debug mode, -s:stop/debug mode, -q:quiet mode, -r:runtime
# If no flags are passed custom logs will be generated in runtests.q
while getopts ":dsqr:" opt; do
  case $opt in
    d ) debug="-debug" ;;
    s ) debug="-debug";stop="-stop" ;;
    q ) quiet="-q" ;;
    r ) run=$OPTARG ;;
    \?) echo "Usage: run.sh [-d] [-s] [-q] [-r runtimestamp]" && exit 1 ;;
    : ) echo "$OPTARG requires an argument" && exit 1 ;;
  esac
done

# Path to test directory
testpath=${KDBTESTS}/stp/subfile

${TORQHOME}/torq.sh start discovery1 stp1 rdb1 -csv ${testpath}/process.csv

/usr/bin/rlwrap q ${TORQHOME}/torq.q \
  -proctype test -procname test1 \
  -test ${testpath} \
  -load ${KDBTESTS}/helperfunctions.q ${testpath}/settings.q \
  -results ${KDBTESTS}/stp/results/ \
  -procfile ${testpath}/process.csv \
  -runtime $run \
  $debug $stop $quiet

${TORQHOME}/torq.sh stop discovery1 stp1 rdb1 -csv ${testpath}/process.csv