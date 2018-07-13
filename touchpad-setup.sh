#!/bin/bash

if [[ "$HOSTNAME" == 'kos-Inspiron-5565' ]]; then
  xinput set-prop 'DELL0769:00 06CB:7E92 Touchpad' 'libinput Tapping Enabled' 1
fi

if [[ "$HOSTNAME" == 'host-kos-pc' ]]; then
  xset m 20/10 45 r rate 300 20 b off
  xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
  xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Scroll Method Enabled' 0, 1, 0
fi
