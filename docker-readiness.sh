#!/bin/bash

if [ -f 'INSTALLING.LOCK' ]; then
   echo "Found INSTALLING.LOCK - still installing - FAIL"
   exit 1
else
   echo "Installing done, checking game status"
fi

coproc MONITOR { ./lgsm-gameserver monitor; }
MONITOR_PID_=$MONITOR_PID
while IFS= read -r line
do 
   echo $line
   if [[ $line =~ "DELAY" ]]; then
      echo "Inside start delay - FAIL"
      exit 1
   fi
   # echo "$i";
done <&"$MONITOR"
wait "$MONITOR_PID_"; exit $?
