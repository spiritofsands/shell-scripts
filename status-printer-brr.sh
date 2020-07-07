#!/bin/bash

set -e

arg_1="${1?}"

top_processes(){
    type="${1?}"
    mapfile -t processes < <(top -b -n 1 -o "+%$type" | head -9 | tail -2)

    declare -A column
    column[CPU]=42
    column[MEM]=48
    names=()
    loads=()
    counter=0
    for process in "${processes[@]}"; do
        cpu_load="$(echo "$process" | cut -c "${column[$type]}"- | cut -c -5)"
        cpu_load="${cpu_load// /}"
        process_name="$(echo "$process" | cut -c 64-)"
        process_name="${process_name::12}"
        if [[ ! $cpu_load =~ ^\ +$ ]]; then
            names+=("$process_name")
            loads+=("$cpu_load")
            counter="$((counter + 1))"
        fi
    done

    echo -n "$type: "
    if [[ "$counter" -gt 0 ]]; then
        for ((i=0; i < counter; i++)) do
            echo -n "${names[i]} ${loads[i]}%"
            if [[ "$i" -lt "$((counter - 1))" ]]; then
                echo -n ', '
            fi
        done
    else
        echo -n 'none'
    fi
}

cpu_processes(){
    top_processes 'CPU'
}

mem_processes(){
    top_processes 'MEM'
}

to_bytes(){
    value="${1?}"
    postfix="${value//[[:digit:]]/}"
    postfix="${postfix//./}"
    number="${value//[[:alpha:]]/}"

    declare -A multiplier
    multiplier[G]=3
    multiplier[Gi]=3
    multiplier[M]=2
    multiplier[K]=1
    multiplier[Ki]=1
    multiplier[B]=1/1024

    if [[ "$postfix" == 'Gi' || "$postfix" == 'G' || "$postfix" == 'M' || "$postfix" == 'Ki' || "$postfix" == 'K' || "$postfix" == 'B' ]]; then
        current_multiplier="$((1024 * "${multiplier[$postfix]}"))"
    else
        echo "unk: $postfix"
        exit 1
    fi

    bc <<<"scale=2; $number * $current_multiplier"
}

get_percent(){
    first="${1?}"
    second="${2?}"

    first_bytes="$(to_bytes "$first")"
    second_bytes="$(to_bytes "$second")"

    bc <<<"$first_bytes * 100 / $second_bytes"
}

load(){
    echo -n "$(uptime | sed -e 's/.*load average:/Load/' -e 's/,.*//')"
}

temp(){
    echo -n "$(sensors | grep 'Package id 0' | sed -e 's/Package id 0: */Temp /' -e 's/ *(.*//')"
}

swap(){
    first="$(free -h | grep 'Swap' | awk '{print $3}')"
    second="$(free -h | grep 'Swap' | awk '{print $2}')"
    echo -n "Swap $(get_percent "$first" "$second")%"
}

mem(){
    first="$(free -h | grep 'Mem' | awk '{print $3}')"
    second="$(free -h | grep 'Mem' | awk '{print $2}')"
    echo -n "Mem $(get_percent "$first" "$second")%"
}

space(){
    used="$(df -h | grep '/$' | awk '{print $3}')"
    total="$(df -h | grep '/$' | awk '{print $2}')"
    echo -n "Used space $(get_percent "$used" "$total")%"
}

uptime_short(){
    echo -n "$(uptime -p | sed -e 's/up/Uptime/' -e 's/,.*$//')"
}

# call func
"$arg_1"
