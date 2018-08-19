#!/bin/bash

sleep 2

while ! tmux ls | rg test -q; do
  sleep '1s'
done

urxvt -e tmux a -t test &

while ! wmctrl -l | rg 'tmux'; do
  sleep '1s'
done
wmctrl -r "tmux" -t 5
