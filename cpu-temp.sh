#!/bin/bash
temp="$(cat /sys/class/thermal/thermal_zone0/temp)"
echo ${temp::-3}
