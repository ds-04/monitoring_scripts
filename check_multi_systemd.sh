#!/bin/bash

#Author D Simpson 2021
#Script takes multiple args and uses an array to check... if any single service fails a check the overall checks stop - so you must fix that service

# Reference Define Nagios return codes
#
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


#check args
if [[ $# -lt 1 ]]; then
    echo "Usage: ${0##*/} <service name>"
    exit $STATE_UNKNOWN
fi

array=( "$@" )
arraylength=${#array[@]}

#firstly, check services exist
for (( i=0; i<${arraylength}; i++ ));
do
   # DEBUG echo "${array[$i]}"
   #check unit-files for arg/var
   status=$(systemctl list-unit-files "${array[$i]}.service" 2>/dev/null)
   check_nounits=`echo ${status}|grep "0 unit files listed"`
   r=$?
   if [[ $r -eq 0 ]]; then
     echo "ERROR: service ${array[$i]} doesn't exist (list-unit-files check)"
     exit $STATE_CRITICAL
   fi
done

#next, check services are running
for (( i=0; i<${arraylength}; i++ ));
do
  #check if service running
  systemctl --quiet is-active "${array[$i]}.service"
  if [[ $? -ne 0 ]]; then
    echo "ERROR: service ${array[$i]} is NOT RUNNING! ---- ALL CHECKS HALTED for services: $@"
    exit $STATE_CRITICAL
  fi
done

echo "OK: services $@ are running"
exit $STATE_OK
