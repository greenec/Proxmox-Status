#!/bin/bash

# abort if apcaccess is not installed
if [ ! -f /sbin/apcaccess ]; then
    exit
fi

ups_info=$(/sbin/apcaccess)

nominal_power=$(awk '{ if ($1 == "NOMPOWER") { print $3 } }' <<< "$ups_info")
power_unit=$(awk '{ if ($1 == "NOMPOWER") { print $4 } }' <<< "$ups_info")
load_percent=$(awk '{ if ($1 == "LOADPCT") { print $3 } }' <<< "$ups_info")
time_left=$(awk '{ if ($1 == "TIMELEFT") { print $3 " " $4 } }' <<< "$ups_info")

power=$(bc <<< "scale=2; $nominal_power * $load_percent / 100.0")

echo "APC UPS Draw: $power $power_unit ($load_percent %)"
echo "Time Remaining: $time_left"

