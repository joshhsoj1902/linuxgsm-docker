#!/bin/bash

if [ -f 'INSTALLING.LOCK' ]; then
   echo "INSTALLING.LOCK found - PASS"
   exit 0
fi
