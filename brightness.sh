#!/bin/bash

current="$(cat /sys/class/backlight/radeon_bl0/brightness)"
max="$(cat /sys/class/backlight/radeon_bl0/max_brightness)"
step=5

if [[ ${1} == '-inc' ]]; then
    ((current+=${step}))
    if [[ ${current} -gt ${max} ]]; then
        # current=${max} already
        exit 0
    fi
elif [[ ${1} == '-dec' ]]; then
    ((current-=${step}))
    if [[ ${current} -lt 0 ]]; then
        current=1
    fi
fi

echo $current
echo ${current} > /sys/class/backlight/radeon_bl0/brightness
