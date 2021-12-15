#!/bin/bash

dir=$(dirname $(realpath "$0"))
source $dir/../config.sh


output=$(
        for disk in ${ssds[@]}; do
                realpath=$(realpath "/dev/disk/by-id/$disk")
                ssdtemp=$(sudo hddtemp -D "$realpath" | awk '$0 ~ /field\(190\)/ { print $3 }')

                printf "$realpath: $ssdtemp\u00b0C|[$disk]\n"
        done
)

# sort output by disk letter, e.g. /dev/sda
printf "$output" | sort | column -t -s '|'

