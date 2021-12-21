#!/bin/bash

dir=$(dirname "$(realpath "$0")")
source "$dir/../config.sh"

# print cpu temperature
temp=$(sensors "$cpu_temp_device" | awk -v field_label="$cpu_temp_field_label" -v print_fmt="$cpu_temp_awk_print_fmt" 'match($0, field_label) { print $print_fmt }')

column -t -s '|' <<< "$(
	# print load average info
	awk '{ print( "Load average:|" $1 " (1m)\t" $2 " (5m)\t" $3 " (15m)" ) }' < /proc/loadavg

	printf "%s:|%s\n" "$cpu_temp_device" "$temp"
)"

