#!/bin/bash

# elevate to root before doing anything so the sudo prompt doesn't disrupt the script 
sudo echo 0 > /dev/null

screenfetch

dir=$(dirname $(realpath "$0"))

printf "\nCPU Load / Temperature:\n"
$dir/scripts/cpuinfo.sh | sed 's/^/\t/'

printf "\nWD Red HDD Temperatures:\n"
$dir/scripts/hddtemp.sh | sed 's/^/\t/'

ssdtemp=$($dir/scripts/ssdtemp.sh)
if [ ! -z "$ssdtemp" ]; then
	printf "\nSSD Temperatures:\n"
	sed 's/^/\t/' <<< "$ssdtemp"
fi

optanetemp=$($dir/scripts/optanetemp.sh)
if [ ! -z "$optanetemp" ]; then
	printf "\nIntel Optane SLOG Temperatures:\n"
	sed 's/^/\t/' <<< "$optanetemp"
fi

printf "\nZFS Adaptive Read Cache Stats:\n"
$dir/scripts/arcstats.sh | sed 's/^/\t/'

