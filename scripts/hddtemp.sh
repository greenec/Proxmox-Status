#!/bin/bash

dir=$(dirname $(realpath "$0"))
source $dir/../config.sh


output=$(
        for disk in ${harddisks[@]}; do
                realpath=$(realpath "/dev/disk/by-id/$disk")
                hddtemp=$(sudo hddtemp "$realpath")

                printf "$hddtemp|[$disk]\n"
        done
)

# sort output by disk letter, e.g. /dev/sda
printf "$output" | sort | column -t -s '|'

