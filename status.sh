#!/bin/bash

# elevate to root before doing anything so the sudo prompt doesn't disrupt the script 
sudo echo 0 > /dev/null

screenfetch

dir=$(dirname $(realpath "$0"))

printf "\nCPU Load / Temperature:\n"
$dir/scripts/cpuinfo.sh | sed 's/^/\t/'

apcstats=$($dir/scripts/apcstats.sh)
if [ ! -z "$apcstats" ]; then
	printf "\nUPS Stats:\n"
	$dir/scripts/apcstats.sh | sed 's/^/\t/'
fi

printf "\nHard Drive Temperatures:\n"
$dir/scripts/disktemp.sh harddisks | sed 's/^/\t/'

ssdtemp=$($dir/scripts/disktemp.sh ssds)
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

