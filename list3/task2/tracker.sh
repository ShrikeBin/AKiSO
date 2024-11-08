#!/bin/bash

readable_bytes() 
{
    local size=$1
    if (( size < 1024 )); then
        echo "${size}B"
    elif (( size < 1048576 )); then
        echo "$(echo "scale=2; $size/1024" | bc)KB"
    elif (( size < 1073741824 )); then
        echo "$(echo "scale=2; $size/1048576" | bc)MB"
    else
        echo "$(echo "scale=2; $size/1073741824" | bc)GB"
    fi
}

cpu_info() 
{
    while read -r line; do
        if [[ "$line" =~ ^cpu[0-9]+ ]]; then

            cpu_id="${line%% *}"

            cpu_stats=($line)
            
            user="${cpu_stats[1]}"
            nice="${cpu_stats[2]}"
            system="${cpu_stats[3]}"
            idle="${cpu_stats[4]}"
            iowait="${cpu_stats[5]}"
            irq="${cpu_stats[6]}"
            softirq="${cpu_stats[7]}"
            
            total=$((user + nice + system + idle + iowait + irq + softirq))
            used=$((user + nice + system + iowait + irq + softirq))
            
            # Calculate CPU usage percentage
            if ((total != 0)); then
                percent=$((100 * used / total))
            else
                percent=0
            fi

            if [[ -e "/sys/devices/system/cpu/$cpu_id/cpufreq/scaling_cur_freq" ]]; then
                freq=$(cat /sys/devices/system/cpu/$cpu_id/cpufreq/scaling_cur_freq)
                freq=$((freq / 1000))  
            else
                freq=0 
            fi

            echo -e "CPU $cpu_id | Usage: $percent% | Frequency: ${freq}MHz"
        fi
    done < /proc/stat
}

memory_info() 
{
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    mem_cached=$(awk '/^Cached/ && !/SwapCached/ {print $2}' /proc/meminfo)  ## to not read SwapCached
    
    mem_used=$((mem_total - mem_free - mem_buffers - mem_cached))

    mem_total_gb=$(echo "scale=2; $mem_total/1048576" | bc)
    mem_used_gb=$(echo "scale=2; $mem_used/1048576" | bc)
    
    echo -e "Memory Usage: $mem_used_gb GB / $mem_total_gb GB"
}

network_info() 
{
    # Take the topmost interface
    interface=$(awk 'NR>2 {print $1, $2}' /proc/net/dev | sort -k2 -n | tail -n 1 | awk '{gsub(":", "", $1); print $1}')
    
    # Check if the interface exists in /proc/net/dev
    if ! grep -qw "$interface" /proc/net/dev; then
        echo "Interface $interface not found!"
        return 1
    fi

    #substitute : to "" (for some reason it doesnt work other way)
    rx_prev=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $2}' /proc/net/dev)
    tx_prev=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $10}' /proc/net/dev)
    
    sleep 1
    
    # Read the current
    rx_curr=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $2}' /proc/net/dev)
    tx_curr=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $10}' /proc/net/dev)

    rx_speed=$((rx_curr - rx_prev))
    tx_speed=$((tx_curr - tx_prev))

    rx_speed_hr=$(readable_bytes $rx_speed)
    tx_speed_hr=$(readable_bytes $tx_speed)

    max_bar_length=50
    max_speed=10000000

    # Scale the bar length based on the current speed (scaled to max_bar_length)
    rx_bar_length=$((rx_speed * max_bar_length / max_speed))
    tx_bar_length=$((tx_speed * max_bar_length / max_speed))

    # Generate the bars (scaled with a limit)
    rx_bar=$(printf "%-${rx_bar_length}s" | tr ' ' '#')
    tx_bar=$(printf "%-${tx_bar_length}s" | tr ' ' '#')

    echo -e "Network - IN Speed: $rx_speed_hr $rx_bar"
    echo -e "Network - OUT Speed: $tx_speed_hr $tx_bar"
}



uptime_info() 
{   
    uptime_seconds=$(awk '{print $1}' /proc/uptime)
    uptime_seconds=${uptime_seconds%.*}

    uptime_days=$((uptime_seconds / 86400))
    uptime_seconds=$((uptime_seconds % 86400))
    uptime_hours=$((uptime_seconds / 3600))
    uptime_seconds=$((uptime_seconds % 3600))
    uptime_minutes=$((uptime_seconds / 60))
    uptime_seconds=$((uptime_seconds % 60)) 

    echo -e "Uptime: ${uptime_days}[d] ${uptime_hours}[h] ${uptime_minutes}[m] ${uptime_seconds}[s]"
}

battery_info() 
{
    if [[ -f /sys/class/power_supply/BAT0/uevent ]]; then
        battery_status=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_CAPACITY=" | cut -d'=' -f2)
        echo -e "Battery: $battery_status%"
    else
        echo -e "Battery: Not available"
    fi
}

loadavg_info() 
{
    loadavg=$(cat /proc/loadavg | awk '{print $1*100"%", $2*100"%", $3*100"%"}')

    echo -e "Load Average (last 1, 5, 15 min): $loadavg"
}


while true; do

    clear 

    cpu_info
    memory_info
    uptime_info
    battery_info
    loadavg_info
    network_info

    sleep 1
done
