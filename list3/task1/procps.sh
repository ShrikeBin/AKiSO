#!/bin/bash

# Print header
echo -e "PPID\tPID\tCOMM\tSTATE\tTTY\tRSS\tPGID\tSID\tOPEN_FILES"

# Loop over all /proc directories that are process IDs
for pid in /proc/[0-9]*; do
    # Extract PID number from directory name
    pid="${pid##*/}"
    
    # Check if process information files exist
    if [[ -r /proc/$pid/status && -r /proc/$pid/stat && -r /proc/$pid/fd ]]; then
        # Get information from /proc/PID/status
        ppid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status)
        comm=$(awk '/^Name:/ {print $2}' /proc/$pid/status)
        state=$(awk '/^State:/ {print $2}' /proc/$pid/status)
        rss=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status)
        
        # Get information from /proc/PID/stat
        tty=$(awk '{print $7}' /proc/$pid/stat)
        pgid=$(awk '{print $5}' /proc/$pid/stat)
        sid=$(awk '{print $6}' /proc/$pid/stat)
        
        # Count number of open file descriptors
        open_files=$(ls /proc/$pid/fd 2>/dev/null | wc -l)
        
        # Handle cases where values may be empty
        rss=${rss:-0}      # If rss is empty, set to 0
        tty=${tty:-'?'}

        # Output process information in a formatted line
        echo -e "$ppid\t$pid\t$comm\t$state\t$tty\t$rss\t$pgid\t$sid\t$open_files"
    fi
done | column -t -s $'\t'

