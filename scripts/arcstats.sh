#!/bin/bash

arcstats_file="/proc/spl/kstat/zfs/arcstats"
zilstats_file="/proc/spl/kstat/zfs/zil"

if [ ! -f "$arcstats_file" ]; then
    exit 1
fi

print_raw=false
if [[ $1 == "--print-raw" ]]; then
	print_raw=true
fi

numfmt_bytes="numfmt --to=iec-i --suffix=B --format=%0.1f"
if [ "$print_raw" = true ]; then
	numfmt_bytes="tee /dev/null"
fi

# add a space between the number and unit, e.g. 53GiB -> 53 GiB
iec_space_regexp="s/([0-9])([A-Z])/\1 \2/"


# get current and max ARC size
arc_size=$(awk '{ if ($1 == "size") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")
max_arc_size=$(awk '{ if ($1 == "c_max") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")

# calculate ARC hit ratio
hits=$(awk '{ if ($1 == "hits") print $3 }' "$arcstats_file")
misses=$(awk '{ if ($1 == "misses") print $3 }' "$arcstats_file")
total_arc_requests=$(( hits + misses ))

# exit if ARC cache has not been used
if [ "$total_arc_requests" -eq 0 ]; then
    exit 1
fi

hit_ratio=$( bc <<< "scale=2; $hits * 100 / $total_arc_requests" )

mfu_size=$(awk '{ if ($1 == "mfu_size") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")
mru_size=$(awk '{ if ($1 == "mru_size") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")
metadata_cache_size=$(awk '{ if ($1 == "arc_meta_used") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")
dnode_cache_size=$(awk '{ if ($1 == "dnode_size") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")

arc_utilization=$(
	printf "|ARC Size:|%s|%s" "$arc_size" "$max_arc_size"
	if [ "$print_raw" = false ]; then
		printf " (Max)"
	fi
	printf "\n"

	printf "|Hit Ratio:|%s" "$hit_ratio"
	if [ "$print_raw" = false ]; then
		printf " %%"
	fi
	printf "\n"

	printf "|MFU Size:|%s \n" "$mfu_size"
	printf "|MRU Size:|%s \n" "$mru_size"
	printf "|Metadata Cache Size:|%s \n" "$metadata_cache_size"
	printf "|Dnode Cache Size:|%s \n" "$dnode_cache_size"
)


# get the size and number of transactions written to the SLOG pool
slog_transaction_count=$(awk '{ if ($1 == "zil_itx_metaslab_slog_count") print $3 }' "$zilstats_file")
slog_transaction_bytes=$(awk '{ if ($1 == "zil_itx_metaslab_slog_bytes") print $3 }' "$zilstats_file")

slog_transaction_size=$($numfmt_bytes <<< "$slog_transaction_bytes" | sed -E "$iec_space_regexp")

# calculate transactions and bytes per second
uptime=$(awk '{ print $1 }' /proc/uptime)
slog_tps=$( bc <<< "scale=1; $slog_transaction_count / $uptime"  )
slog_bytes_per_sec=$( bc <<< "scale=2; $slog_transaction_bytes / $uptime" | $numfmt_bytes | sed -E "$iec_space_regexp" )

zil_utilization=$(
	printf "|ZIL SLOG Transactions:|%s \n" "$slog_transaction_size"

	printf "|ZIL SLOG TPS:|%s" "$slog_tps"
	if [ "$print_raw" = false ]; then
		printf " itx/sec"
	fi
	printf "\n"

	printf "|ZIL SLOG Writes:|%s" "$slog_bytes_per_sec"
	if [ "$print_raw" = false ]; then
		printf "/sec"
	fi
	printf "\n"


)


# get the size and hit ratio of the L2ARC
l2arc_size=$(awk '{ if ($1 == "l2_size") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")
l2arc_size_compressed=$(awk '{ if ($1 == "l2_asize") print $3 }' "$arcstats_file" | $numfmt_bytes | sed -E "$iec_space_regexp")

# calculate L2ARC hit ratio
l2_hits=$(awk '{ if ($1 == "l2_hits") print $3 }' "$arcstats_file")
l2_misses=$(awk '{ if ($1 == "l2_misses") print $3 }' "$arcstats_file")
total_l2_arc_requests=$(( l2_hits + l2_misses ))
l2arc_hit_ratio=$( bc <<< "scale=2; $l2_hits * 100 / $total_l2_arc_requests" )

l2arc_stats=$(
	echo "|L2ARC Size:|$l2arc_size"
	echo "|L2ARC Size (compressed):|$l2arc_size_compressed"

	printf "|L2ARC Hit Ratio:|$l2arc_hit_ratio"
	if [ "$print_raw" = false ]; then
		printf " %%"
	fi
	printf "\n"
)

output=$(
	printf "ARC Stats:\n%s\n" "$arc_utilization"

	if [ "$slog_transaction_count" != "0" ]; then
		printf "ZIL Stats:\n%s\n" "$zil_utilization"
	fi

	if [ -n "$l2arc_size" ]; then
		printf "L2ARC Stats:\n%s\n" "$l2arc_stats"
	fi
)

if [ "$print_raw" = true ]; then
	echo "$output"
else
	# print final output in table format
	column -t -s '|' <<< "$output"
fi
