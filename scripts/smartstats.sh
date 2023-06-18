#!/bin/bash

CYAN='\033[0;36m'
NC='\033[0m'

dir=$(dirname "$(realpath "$0")")
source "$dir/../config.sh"

header_printed=false

for disk in "${harddisks[@]}"; do
	smartctl_cmd="/sbin/smartctl -a /dev/disk/by-id/$disk"
	if [ "$EUID" -ne 0 ]; then
		smartctl_cmd="sudo $smartctl_cmd"
	fi
	smartctl=$(eval "$smartctl_cmd")

	if [ "$header_printed" = false ]; then
		echo "$smartctl" | grep 'ID#'
		header_printed=true
	fi

	printf "${CYAN}${disk}${NC}\n"
	echo "$smartctl" | grep 'Reallocated_Sector_Ct'
	echo "$smartctl" | grep 'Current_Pending_Sector'
	printf "\n"
done

