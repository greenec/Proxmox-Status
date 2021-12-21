#!/bin/bash

harddisks=(	"ata-WDC_WD40EFRX-68N32N0_WD-1"
			"ata-WDC_WD40EFRX-68N32N0_WD-S"
			"ata-WDC_WD40EFRX-68N32N0_WD-1"
			"ata-WDC_WD40EFRX-68N32N0_WD-5"
			"ata-WDC_WD40EFZX-68AWUN0_WD-9"
			"ata-WDC_WD40EFZX-68AWUN0_WD-J"
			"ata-WDC_WD40EFZX-68AWUN0_WD-7" )

optanedrives=(	"nvme-pci-0100"
				"nvme-pci-0400" )

ssds=(	"ata-Samsung_SSD_860_EVO_500GB_T"
		"ata-Samsung_SSD_860_EVO_500GB_R"
		"ata-Samsung_SSD_860_EVO_500GB_K"
		"ata-Samsung_SSD_860_PRO_256GB_X"
		"ata-Samsung_SSD_860_PRO_256GB_W" )



# sample output from sensors
# k10temp-pci-00c3
# Adapter: PCI adapter
# Tctl:         +53.5°C
# Tdie:         +53.5°C
# Tccd1:        +42.8°C

cpu_temp_device="k10temp-pci-00c3"
cpu_temp_field_label="Tdie"
cpu_temp_awk_print_fmt="2"

show_screenfetch=true
