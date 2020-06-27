#!/bin/bash

if [ -f 'INSTALLING.LOCK' ]; then
   echo "Found INSTALLING.LOCK - still installing - FAIL"
   exit 1
else
   echo "Installing done, checking game status"
fi

exec 5>&1
monitor_output=$(./lgsm-gameserver monitor|tee /dev/fd/5)

echo $monitor_output
