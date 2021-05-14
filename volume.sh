#!/bin/bash

usage() {
    echo "$0 --inc [NUMBER] | --dec [NUMBER] | --mute-volume | --mute-mic"
    exit 1
}

current_sink() {
    pactl list short sinks | head -c1
}

current_input() {
    pactl list sources short | grep input | head -c1
}

readonly ACTION="${1}"
readonly VOL="${2:-5%}"

if [[ -z $ACTION ]]; then
    usage
fi

case "$ACTION" in
    --inc)
        pactl set-sink-volume "$(current_sink)" "+$VOL"
        ;;
    --dec)
        pactl set-sink-volume "$(current_sink)" "-$VOL"
        ;;
    --mute-volume)
        pactl set-sink-mute "$(current_sink)" toggle
        ;;
    --mute-mic)
        pactl set-source-mute "$(current_input)" toggle
esac
