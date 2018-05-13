#!/bin/bash

if [ -f 'INSTALLING.LOCK' ]; then
   echo "INSTALLING.LOCK found - PASS"
   exit 0
fi

monitorstring=$(./lgsm-gameserver monitor)
echo monitorstring: "$monitorstring"
failcount=$(echo "$monitorstring" | grep -oh 'FAIL\|ERROR' | wc -w)
startingcount=$(echo "$monitorstring" | grep -oh 'Starting' | wc -w)
# okcount=$(echo "$monitorstring" | grep OK | wc -c)

echo startingcount: $startingcount
echo failcount: $failcount
# echo $okcount
if [ "$failcount" -gt "0" ]
then
  echo "FAIL"
  exit 1
else
  echo "PASS"
  exit 0
fi
