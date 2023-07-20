#!/bin/bash

sudo apt update
sudo apt install screenfetch lm-sensors smartmontools

echo

echo "If you haven't already, please run 'sudo sensors-detect' to configure temperature sensors" \
	 "for your CPU and other devices which detect temperature like NVMe drives."

