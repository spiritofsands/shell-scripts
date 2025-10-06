#!/bin/bash

print_mem() {
	local mem="$1"
	local last_size=0
	local units=(Kb Mb Gb Tb)
	local i=0

	while [[ "$(bc <<<"$mem>1")" -eq 1 ]]; do
		last_size="$mem ${units[$i]}"
		i=$((i + 1))
		mem="$(bc <<<"scale=1; $mem / 1024")"
	done
	echo "$last_size"
}

ps -eo 'pmem=,pcpu=,vsize=,cmd=' | sort -k 1 -nr | head -50 | awk '{print $4}' | sort -u | while read -r cmd; do
	mem="$(smem -t -c pss -P "$cmd" | tail -n 1)"
	cmd_name="${cmd##*/}"
	echo "${cmd_name:0:20} $mem $(print_mem "$mem")"
done | sort -k 2 -n -r | awk '{$2=""; printf "%-20s %7s %s\n", $1, $3, $4}'
