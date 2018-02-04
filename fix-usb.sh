#!/bin/bash

if [[ $(whoami) != 'root' ]]; then
  echo "Run me with sudo"
  exit 1
fi

for usb in /sys/bus/usb/devices/*/power/control; do
  if [[ "$(cat $usb)" != 'on' ]]; then
    echo 'on' > "$usb"
    echo "Fixed: $usb"
  fi
done
