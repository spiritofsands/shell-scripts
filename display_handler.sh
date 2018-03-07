#!/bin/bash

restart_stuff() {
  ~/.fehbg
  killall keynav
  sleep 5s
  keynav
}

if [[ "$(hostname)" == 'kos-Inspiron-5565' ]]; then
  laptop='eDP'
  external='HDMI-A-0'
elif [[ "$(hostname)" == 'kos-pc' ]];then
  laptop='LVDS'
  external='HDMI-0'
else
  exit 1
fi


status="$(cat "/sys/class/drm/card0-HDMI-A-1/status")"
case "$status" in
  "connected")
    xrandr --output "$laptop" --off
    xrandr --output "$external" --auto
    restart_stuff
    ;;
  "disconnected")
    xrandr --output "$external" --off
    xrandr --output "$laptop" --auto --fb 1366x768
    restart_stuff
    ;;
esac
