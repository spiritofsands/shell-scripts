#!/bin/bash
readonly TMPBG=/tmp/screen.png
readonly LOCK=$HOME/bin/.lock.png
readonly RES=$(xrandr | grep 'current' | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')
readonly UNUSED_WORKSPACE=7

i3 workspace number "$UNUSED_WORKSPACE"

ffmpeg -f x11grab -video_size "$RES" -y -i "$DISPLAY" -i "$LOCK" -filter_complex "boxblur=5:10,overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" -vframes 1 $TMPBG -loglevel quiet

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

i3 workspace back_and_forth

rm "$TMPBG"
