#!/bin/bash

if [ -f 'INSTALLING.LOCK' ]; then
   echo "Found INSTALLING.LOCK - still installing - FAIL"
   exit 1
fi