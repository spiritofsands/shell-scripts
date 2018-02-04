#!/bin/sh

restart_stuff() {
  killall keynav
  killall feh
  keynav
  ~/.fehbg
}

case "$SRANDRD_ACTION" in
  "HDMI-A-0 connected")
    xrandr --output eDP --off
    xrandr --output HDMI-A-0 --auto
    restart_stuff
    ;;
  "HDMI-A-0 disconnected")
    xrandr --output HDMI-A-0 --off
    xrandr --output eDP --auto --fb 1366x768
    restart_stuff
    ;;
esac
