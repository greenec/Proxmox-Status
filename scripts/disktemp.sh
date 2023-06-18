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
		hddtemp_cmd="/sbin/hddtemp $realpath 2>&1"
		if [ "$EUID" -ne 0 ]; then
			hddtemp_cmd="sudo $hddtemp_cmd"
		fi
		hddtemp=$(eval "$hddtemp_cmd")

		# handle SSDs which use a different field for temperature
		if [[ "$hddtemp" == *"doesn't seem to have a temperature sensor"* ]]; then
			realpath=$(realpath "/dev/disk/by-id/$disk")
			ssdtemp_cmd="/sbin/hddtemp -D $realpath | awk '/field\(190\)/ { print \$3 }'"
			diskname_cmd="/sbin/smartctl -a $realpath | sed -n 's/Device Model:\s*\(.*\)/\1/p'"
			if [ "$EUID" -ne 0 ]; then
				ssdtemp_cmd="sudo $ssdtemp_cmd"
				diskname_cmd="sudo $diskname_cmd"
			fi
			ssdtemp=$(eval "$ssdtemp_cmd")
			diskname=$(eval "$diskname_cmd")

			printf "%s:|%s:|%s\u00b0C:|[%s]\n" "$realpath" "$diskname" "$ssdtemp" "$disk"
		else
			# add a '|' after each colon so column can align fields to the table
			delimited_hddtemp=$(sed -e 's/:\s*/:|/g' <<< "$hddtemp")
			printf "%s:|[%s]\n" "$delimited_hddtemp" "$disk"
		fi
	done
)

# sort output by disk model, e.g. WDC WD40EFRX-68N32N0
printf "%s" "$output" | sort -k 2 | column -t -s '|'

