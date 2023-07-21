#!/bin/bash

dir=$(dirname "$(realpath "$0")")
source "$dir/../config.sh"

if [ "$1" == "optane" ]; then
        disks=("${optanedrives[@]}")
else
        disks=("${nvmedrives[@]}")
fi


output=$(
	for disk in "${disks[@]}"; do
		realpath=$(realpath "/dev/disk/by-id/$disk")
		smartctl_cmd="/sbin/smartctl -a $realpath"

		if [ "$EUID" -ne 0 ]; then
			smartctl_cmd="sudo $smartctl_cmd"
		fi

		smartctl=$(eval "$smartctl_cmd")

		disktemp=$(awk '{ if ($1 == "Temperature:") print $2 }' <<< "$smartctl")
		diskname=$(sed -n 's/Model Number:\s*\(.*\)/\1/p' <<< "$smartctl")
		
		printf "%s:|%s:|%s\u00b0C:|[%s]\n" "$realpath" "$diskname" "$disktemp" "$disk"
	done
)

# sort output by disk model, e.g. Samsung SSD 970 EVO Plus 2TB
printf "%s" "$output" | sort -k 2 | column -t -s '|'

