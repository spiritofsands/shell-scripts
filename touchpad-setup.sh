#1/bin/bash

if [[ "$HOSTNAME" == 'kos-Inspirion-5565' ]]; then
  # tap
  xinput set-prop 12 275 1
fi

if [[ "$HOSTNAME" == 'kos-pc' ]]; then
  # tap
  xinput set-prop 14 294 1
  # scroll
  xinput set-prop 14 286 0, 1, 0
fi
