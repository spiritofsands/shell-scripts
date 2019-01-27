#!/bin/bash

current_sink() {
    pactl list short sinks | head -c1
}

update_i3bar() {
    pkill -RTMIN+10 i3blocks
}

readonly ACTION="${1?}"
readonly VOL="${2:-5%}"

case "$ACTION" in
    --inc)
        pactl set-sink-volume "$(current_sink)" "+$VOL"
        update_i3bar
        ;;
    --dec)
        pactl set-sink-volume "$(current_sink)" "-$VOL"
        update_i3bar
        ;;
    --mute)
        pactl set-sink-mute "$(current_sink)" toggle
        update_i3bar
        ;;
esac
