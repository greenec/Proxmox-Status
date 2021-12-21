#!/bin/bash

dir=$(dirname "$(realpath "$0")")
source "$dir/../config.sh"


for disk in "${optanedrives[@]}"; do
	temp=$(sensors "$disk" | awk '/Composite/ { print $2 }')
	printf "%s:\t%s\n" "$disk" "$temp"
done

