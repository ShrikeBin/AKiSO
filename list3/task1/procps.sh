#!/bin/bash

(
    echo -e "PPID\tPID\tCOMM(NAME)\tSTATE\tTTY\tRSS\tPGID\tSID\tOPEN_FILES"

    #  [0-9] only numerical names
    for pid in /proc/[0-9]*; do
        pid="${pid##*/}"
        
        if [[ -r /proc/$pid/status && -r /proc/$pid/stat && -r /proc/$pid/fd ]]; then
            
            ppid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status) # in awk look for line starting (^) with string PPid: and print second after whitespace ($2)
            comm=$(awk '/^Name:/ {print $2}' /proc/$pid/status)
            state=$(awk '/^State:/ {print $2}' /proc/$pid/status)
            rss=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status)
            
            tty=$(awk '{print $7}' /proc/$pid/stat)
            pgid=$(awk '{print $5}' /proc/$pid/stat)
            sid=$(awk '{print $6}' /proc/$pid/stat)
            
            open_files=$(ls /proc/$pid/fd 2>/dev/null | wc -l)
            
            rss=${rss:-0}
            tty=${tty:-'?'}

            echo -e "$ppid\t$pid\t$comm\t$state\t$tty\t$rss\t$pgid\t$sid\t$open_files"
        fi
    done 
)| column -t -s $'\t' | less
