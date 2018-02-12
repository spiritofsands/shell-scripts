#!/bin/sh

restart_stuff() {
  killall keynav
  killall feh
  keynav
  ~/.fehbg
}

status="$(cat /sys/class/drm/card0-HDMI-A-1/status)"
echo "$status" >> /home/kos/status.log
case "$status" in
  "connected")
    xrandr --output eDP --off
    xrandr --output HDMI-A-0 --auto
    #restart_stuff
    ;;
  "disconnected")
    xrandr --output HDMI-A-0 --off
    xrandr --output eDP --auto --fb 1366x768
    #restart_stuff
    ;;
esac
