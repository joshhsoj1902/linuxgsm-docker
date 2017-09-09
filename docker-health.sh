#!/bin/bash

monitorstring=$(./lgsm-gameserver monitor)
echo $monitorstring
failcount=$(echo "$monitorstring" | grep -oh 'FAIL\|ERROR' | wc -w)
# okcount=$(echo "$monitorstring" | grep OK | wc -c)
# echo failcount: $failcount
# echo $okcount
if [ "$failcount" -gt "0" ]
then
  echo "FAIL"
  exit 1
else
  echo "PASS"
  exit 0
fi
