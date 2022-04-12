#!/bin/bash

#Author D Simpson 2021
#Script takes multiple args and uses an array to check... if any single mount fails a check the overall checks stop - so you must fix that mount

# Reference Define Nagios return codes
#
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


#check args
if [[ $# -lt 1 ]]; then
    echo "Usage: ${0##*/} </path/to/mount>"
    exit $STATE_UNKNOWN
fi

array=( "$@" )
arraylength=${#array[@]}

#check
for (( i=0; i<${arraylength}; i++ ));
do
  #check mountpoint ok
  mountpoint "${array[$i]}" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "ERROR: ${array[$i]} is NOT MOUNTED! ---- ALL CHECKS HALTED for mounts: $@"
    exit $STATE_CRITICAL
  fi
done

echo "OK: mounts $@ are present"
exit $STATE_OK
