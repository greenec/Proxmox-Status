#!/bin/bash

dir=$(dirname $(realpath "$0"))
source $dir/../config.sh


awk '{ print( "Load average:\t" $1 " (1m)\t" $2 " (5m)\t" $3 " (15m)" ) }' < /proc/loadavg


echo


temp=$(sensors $cpu_temp_device | awk "\$0 ~ /$cpu_temp_field_label/ { print $cpu_temp_awk_print_fmt }")
printf "%s:\t%s\n" "$cpu_temp_device" "$temp"

