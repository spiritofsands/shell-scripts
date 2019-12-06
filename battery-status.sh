#!/bin/bash

# For default behavior
setDefaults() {
    output_tmux=0
    good_color="1;32"
    middle_color="1;33"
    warn_color="0;31"
}

setDefaults

# Determine battery charge state
battery_charge() {
    battery_path=/sys/class/power_supply/BAT*
    battery_state=$(cat $battery_path/status)
    battery_current=$battery_path/capacity
    BATT_PCT=$(cat $battery_current)
    if [ "$battery_state" != 'Discharging' ]; then
        battery_state=' (on AC)'
    else
        battery_state=''
    fi
}

# Apply the correct color to the battery status prompt
apply_colors() {
    # Green
    if [[ $BATT_PCT -ge 50 ]]; then
        if ((output_tmux)); then
            COLOR="#[fg=$good_color]"
        else
            COLOR=$good_color
        fi

    # Yellow
    elif [[ $BATT_PCT -ge 20 ]] && [[ $BATT_PCT -lt 50 ]]; then
        if ((output_tmux)); then
            COLOR="#[fg=$middle_color]"
        else
            COLOR=$middle_color
        fi

    # Red
    elif [[ $BATT_PCT -lt 20 ]]; then
        if ((output_tmux)); then
            COLOR="#[fg=$warn_color]"
        else
            COLOR=$warn_color
        fi
    fi
}

# Print the battery status
print_status() {
    if ((output_tmux)); then
        printf "%s%s%s" "$COLOR" "BAT: $BATT_PCT%${battery_state}" "#[default]"
    else
        printf "\\e[0;%sm%s\\e[m\\n"  "$COLOR" "BAT: $BATT_PCT%${battery_state}"
    fi
}

# Read args
if [[ "${1}" == '-t' ]]; then
            output_tmux=1
            good_color="green"
            middle_color="yellow"
            warn_color="red"
fi

battery_charge
apply_colors
print_status
