#!/bin/bash

dir=$(dirname $(realpath "$0"))
source $dir/../config.sh

if [ "$1" == "ssds" ]; then
	disks=${ssds[@]}
else
	disks=${harddisks[@]}
fi

output=$(
	for disk in ${disks[@]}; do
		realpath=$(realpath "/dev/disk/by-id/$disk")
		hddtemp=$(sudo hddtemp "$realpath" 2>&1)

		# handle SSDs which use a different field for temperature
		if [[ "$hddtemp" == *"doesn't seem to have a temperature sensor"* ]]; then
			realpath=$(realpath "/dev/disk/by-id/$disk")
			ssdtemp=$(sudo hddtemp -D "$realpath" | awk '$0 ~ /field\(190\)/ { print $3 }')
			diskname=$(sudo smartctl -a "$realpath" | sed -n 's/Device Model:\s*\(.*\)/\1/p')

			printf "$realpath: $diskname: $ssdtemp\u00b0C|[$disk]\n"
		else
			printf "$hddtemp:|[$disk]\n"
		fi
	done
)

# sort output by disk letter, e.g. /dev/sda
printf "$output" | sort | column -t -s '|'

