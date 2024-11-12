#!/bin/bash

convert_bytes() 
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
    (
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

            echo -e "\tCPU $cpu_id \t| \tUsage: $percent% \t| \tFrequency: ${freq}MHz"
        fi
    done < /proc/stat
    ) | column -t -s $'\t' 
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

network_measure()
{
    interface=$(awk 'NR>2 {print $1, $2}' /proc/net/dev | sort -k2 -n | tail -n 1 | awk '{gsub(":", "", $1); print $1}')
    
    if ! grep -qw "$interface" /proc/net/dev; then
        echo "Interface $interface not found!"
        return 1
    fi

    recieve_prev=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $2}' /proc/net/dev)
    transfer_prev=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $10}' /proc/net/dev)
    
    sleep 1

    recieve_curr=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $2}' /proc/net/dev)
    transfer_curr=$(awk -v iface="$interface" '{gsub(":", "", $1); if ($1 == iface) print $10}' /proc/net/dev)

    recieve_speed=$((recieve_curr - recieve_prev))
    transfer_speed=$((transfer_curr - transfer_prev))

    echo "$recieve_speed $transfer_speed"
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

draw_graph()
{
    local values=("${@:2}")

    local max_value=0
    for value in "${values[@]}"; do
        if (( value > max_value )); then
            max_value=$value
        fi
    done

    local max_height=5

    if(( max_value > 0 )); then
        for (( level=$max_height; level>0; level-- )); do
            for value in "${values[@]}"; do
                if (( (value * max_height) / max_value + 1 > level )); then
                    printf "#"
                else
                    printf " "
                fi
            done
            echo
        done
    else
        for (( level=$max_height; level>0; level-- )); do
            echo
        done
    fi

    for value in "${values[@]}"; do
        printf "_"
    done
    echo
}

rx_values=()
tx_values=()
for i in {1..57}; do
    rx_values+=(0)
    tx_values+=(0)
done

while true; do
    read rx tx <<< "$(network_measure)"
    rx_values+=($rx) && unset rx_values[0] && rx_values=("${rx_values[@]}")
    tx_values+=($tx) && unset tx_values[0] && tx_values=("${tx_values[@]}")

    clear 

    recieve_speed=$(convert_bytes $rx)
    echo -e "Network Receive Speed: $recieve_speed"
    draw_graph "Network_Receive: ${rx_values[@]}"

    transfer_speed=$(convert_bytes $tx)
    echo -e "Network Transfer Speed: $transfer_speed"
    draw_graph "Network_Transfer: ${tx_values[@]}"

    echo -e "$(printf '_'%.0s {0..55})"
    echo
    uptime_info
    echo
    loadavg_info
    echo
    battery_info
    echo
    memory_info
    echo -e "$(printf '_'%.0s {0..55})"
    echo -e "$(printf '_'%.0s {0..55})"
    echo
    cpu_info
    echo -e "$(printf '_'%.0s {0..55})"
    echo -e "$(printf '_'%.0s {0..55})"

done