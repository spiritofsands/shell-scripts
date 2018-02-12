#!/bin/bash

if [[ "$HOSTNAME" == 'kos-Inspiron-5565' ]]; then
  xinput set-prop 'DELL0769:00 06CB:7E92 Touchpad' 'libinput Tapping Enabled' 1
fi

if [[ "$HOSTNAME" == 'kos-pc' ]]; then
  xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
  xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Scroll Method Enabled' 0, 1, 0
fi
