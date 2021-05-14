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
        process_name="${process_name::6}"
        if [[ ! $cpu_load =~ ^\ +$ ]]; then
            names+=("$process_name")
            loads+=("$cpu_load")
            counter="$((counter + 1))"
        fi
    done

    echo "$type"
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
    multiplier[Mi]=2
    multiplier[K]=1
    multiplier[Ki]=1
    multiplier[B]=1/1024
    multiplier[Bi]=1/1024

    if [[ "$postfix" == 'G' || "$postfix" == 'M' || "$postfix" == 'K' || "$postfix" == 'B' ]]; then
        one=1000
    else
        one=1024
    fi
    current_multiplier="$((one ** "${multiplier[$postfix]}"))"

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
    echo 'Load'
    echo -n "$(uptime | sed -e 's/.*load average://' -e 's/,.*//')"
}

temp(){
    echo 'Temp'
    echo -n "$(sensors | grep 'Package id 0' | sed -e 's/Package id 0: *//' -e 's/ *(.*//')"
}

swap(){
    first="$(free -h | grep 'Swap' | awk '{print $3}')"
    second="$(free -h | grep 'Swap' | awk '{print $2}')"
    echo 'Swap'
    echo -n "$(get_percent "$first" "$second")%"
}

mem(){
    first="$(free -h | grep 'Mem' | awk '{print $3}')"
    second="$(free -h | grep 'Mem' | awk '{print $2}')"
    echo 'Mem'
    echo -n "$(get_percent "$first" "$second")%"
}

space(){
    used="$(df -h | grep '/$' | awk '{print $3}')"
    total="$(df -h | grep '/$' | awk '{print $2}')"
    echo 'Rootfs'
    echo -n "$(get_percent "$used" "$total")%"
}

disk_usage(){
    statistics="$(iostat -y -d nvme0n1 1 1 -h | grep nvme0n1)"
    read_s="$(echo "$statistics" | awk '{print $3}')"
    write_s="$(echo "$statistics" | awk '{print $4}')"
    echo 'R/W'
    echo -n "${read_s}/s, ${write_s}/s"
}

network_usage(){
    sar -n DEV 1 1
}

uptime_short(){
    echo 'Uptime'
    echo -n "$(uptime -p | sed -e 's/up //' -e 's/,.*$//')"
}

updates(){
    mapfile packages -t < <(apt list --upgradable 2>/dev/null | tail -n +2)
    pkg_number="${#packages[@]}"
    if [[ "$pkg_number" -gt 0 ]]; then
        echo -n "$pkg_number pkg "
    fi

    mapfile wheels -t < <(pip list --outdated --format=freeze)
    whl_number="${#wheels[@]}"
    if [[ "$whl_number" -gt 0 ]]; then
        echo -n "$whl_number whl "
    fi

    # add
    # npm outdated

    vim_plugins_dir="$HOME/.vim/plugged"
    vim_number=0
    for plugin in "$vim_plugins_dir"/*; do
        cd "$plugin"
        git fetch &>/dev/null
        if git status | grep -q 'Your branch is behind'; then
            vim_number=$((vim_number + 1))
        fi
    done
    if [[ "$vim_number" -gt 0 ]]; then
        echo -n "$vim_number vim "
    fi

    tmux_plugins_dir="$HOME/.tmux/plugins"
    tmux_number=0
    for plugin in "$tmux_plugins_dir"/*; do
        cd "$plugin"
        git fetch &>/dev/null
        if git status | grep -q 'Your branch is behind'; then
            tmux_number=$((tmux_number + 1))
        fi
    done
    if [[ "$tmux_number" -gt 0 ]]; then
        echo -n "$tmux_number tmux "
    fi
}

os_info(){
    echo -n "Debian $(cat /etc/debian_version)"
    echo -n ", KDE $(plasmashell --version | sed 's/.*\s//')"
    echo ", Linux $(uname -r)"
    updates_str="$(updates)"
    if [[ -n "$updates_str" ]]; then
        echo -n "Updates: $updates_str"
    else
        echo -n 'Up to date'
    fi
}

# call func
"$arg_1"
