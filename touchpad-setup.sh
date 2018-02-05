#1/bin/bash

if [[ "$HOSTNAME" == 'kos-Inspiron-5565' ]]; then
  # tap
  xinput set-prop 'DELL0769:00 06CB:7E92 Touchpad' 'libinput Tapping Enabled' 1
fi

if [[ "$HOSTNAME" == 'kos-pc' ]]; then
  # tap
  xinput set-prop 14 294 1
  # scroll
  xinput set-prop 14 286 0, 1, 0
fi
