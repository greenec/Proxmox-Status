#!/bin/bash

CYAN='\033[0;36m'
NC='\033[0m'

# elevate to root before doing anything so the sudo prompt doesn't disrupt the script 
sudo echo 0 > /dev/null

dir=$(dirname "$(realpath "$0")")
source "$dir/config.sh"

# measure CPU temp before running screenfetch so it's more accurate
cpuinfo=$("$dir/scripts/cpuinfo.sh")

if [[ "$show_screenfetch" = true ]]; then
	screenfetch
	printf "\n"
fi

printf "${CYAN}CPU Load / Temperature:${NC}\n"
sed 's/^/\t/' <<< "$cpuinfo"

apcstats=$("$dir/scripts/apcstats.sh")
if [ -n "$apcstats" ]; then
	printf "\n${CYAN}UPS Stats:${NC}\n"
	sed 's/^/\t/' <<< "$apcstats"
fi

hddtemp=$("$dir/scripts/disktemp.sh" harddisks)
if [ -n "$hddtemp" ]; then
	printf "\n${CYAN}Hard Drive Temperatures:${NC}\n"
	sed 's/^/\t/' <<< "$hddtemp"
fi

ssdtemp=$("$dir/scripts/disktemp.sh" ssds)
if [ -n "$ssdtemp" ]; then
	printf "\n${CYAN}SSD Temperatures:${NC}\n"
	sed 's/^/\t/' <<< "$ssdtemp"
fi

nvmetemp=$("$dir/scripts/nvmetemp.sh")
if [ -n "$nvmetemp" ]; then
	printf "\n${CYAN}NVMe SSD Temperatures:${NC}\n"
	sed 's/^/\t/' <<< "$nvmetemp"
fi

optanetemp=$("$dir/scripts/optanetemp.sh")
if [ -n "$optanetemp" ]; then
	printf "\n${CYAN}Intel Optane SLOG Temperatures:${NC}\n"
	sed 's/^/\t/' <<< "$optanetemp"
fi

printf "\n${CYAN}ZFS Adaptive Read Cache Stats:${NC}\n"
"$dir/scripts/arcstats.sh" | sed 's/^/\t/'

