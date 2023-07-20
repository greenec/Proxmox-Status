#!/bin/bash

dir=$(dirname "$(realpath "$0")")
source "$dir/../config.sh"

if [ "$1" == "ssds" ]; then
	disks=("${ssds[@]}")
else
	disks=("${harddisks[@]}")
fi

output=$(
	for disk in "${disks[@]}"; do
		realpath=$(realpath "/dev/disk/by-id/$disk")
		smartctl_cmd="/sbin/smartctl -a $realpath"

		if [ "$EUID" -ne 0 ]; then
			smartctl_cmd="sudo $smartctl_cmd"
		fi
		smartctl=$(eval "$smartctl_cmd")

		disktemp=$(awk '$2 ~ "Temperature" { print $10 }' <<< "$smartctl")
		diskname=$(sed -n 's/Device Model:\s*\(.*\)/\1/p' <<< "$smartctl")

		printf "%s:|%s:|%s\u00b0C:|[%s]\n" "$realpath" "$diskname" "$disktemp" "$disk"
	done
)

# sort output by disk model, e.g. WDC WD40EFRX-68N32N0
printf "%s" "$output" | sort -k 2 | column -t -s '|'

