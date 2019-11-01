#!/bin/bash
#
#

if [ -z "$1" ] || [ "$1" -gt "14" ]; then
  exit
fi

LAST=$1

for i in $(seq 1 $LAST); do
  xterm & 
  sleep 0.2
done
