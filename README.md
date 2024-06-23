# Proxmox-Status
A bash script to gather system metrics like temperatures and ARC utilization that are missing from the Proxmox UI.

## Sample
![](samples/minotaur-status.png)

## Setup
1. The install script adds 3 packages and expects you to be on Proxmox, a Debian-based system. It adds `screenfetch` `lm-sensors` and `smartmontools`. **If you are okay with this**, run `./installpkgs.sh` and follow the instructions printed at the end of the script
2. Copy `config.sample.sh` to `config.sh`
3. Edit `config.sh` and replace the example variables with your system's disk and CPU names  
3.1 **Configure Disks** - For ZFS users, you should be able to run `sudo zfs status` and see the name for each disk in your zpool that refers to its `/dev/disk/by-id/` path. You can leave the disk arrays empty or omit them entirely if you don't have mechanical drives or Optane drives, for example  
3.2 **Configure CPU** - If you installed `lm-sensors` in step 1, you'll be able to run `sensors` and find the name of your CPU. My Ryzen 3700X is shown in a comment in the sample config as `k10temp-pci-00c3` and the `cpu_temp_awk_print_fmt` is a format string which picks the second word in the example. It runs the format string on the line with the matching `cpu_temp_field_label`, `Tdie` for the temperature of the CPU die in my case.  
3.3 **Configure Screenfetch** - If you did not install `screenfetch` or do not want to see it at the top of the status output, set `show_screenfetch` to false
4. There are some aspects of the status which are implicitly configured.  
4.1 **APC UPS Users** - If you are on an APC brand UPS and have `apcupsd` installed with a USB serial connection to the UPS, it can read the status of you battery and show current draw in Watts and as a percentage of its VA rating. It will also show time remaining in the event of a power outage.  
4.2 **ZFS Users** - `arcstats.sh` determines if you have an `arcstats` file on your system, and whether you have a SLOG or L2ARC, then shows additional details for them if possible.
5. Test by running `./status.sh` and checking that the output shows all of your disks, CPU temp, and ARC stats correctly
