#!/bin/bash

readonly BG="$(grep -oP "(?<=').*(?=')" ~/.fehbg)"
readonly LOCK=$HOME/bin/.lock.png
readonly RES=$(xrandr | grep 'current' | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')
readonly TYPE='png'

TMPBG="/tmp/$(basename "$BG")"
TMPBG="${TMPBG%\.*}.$TYPE"

if [[ ! -f "$TMPBG" ]]; then
    ffmpeg -y -i "$BG" -i "$LOCK" -filter_complex \
        "scale=$RES,boxblur=5:10,overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" \
        -vframes 1 "$TMPBG" -loglevel quiet
fi

pgrep compton > /dev/null
readonly COMPTON_WAS_LAUNCHED=$?
if [[ "$COMPTON_WAS_LAUNCHED" == 0 ]]; then
    pkill compton
fi

i3lock --nofork --image="$TMPBG"

if [[ "$COMPTON_WAS_LAUNCHED" == 0 ]]; then
    compton &
    disown
fi

# delete $TYPE images older tnan 30 days
find /tmp/ -name "*.$TYPE" -mtime +30 -type f -delete 2>/dev/null
