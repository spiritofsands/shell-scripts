#!/bin/bash

if [[ "$HOSTNAME" == 'kos-pc' ]]; then
  ln -s ~/bin/firefox-stable/firefox ~/bin/firefox
  ln -s ~/bin/Telegram/Telegram ~/bin/Telegram
  ln -s ~/bin/tor-browser_en-US/Browser/start-tor-browser ~/bin/torbrowser
fi

ln -s ~/bin/firefox-dev/firefox ~/bin/firefox-dev
ln -s ~/build/go-builds/bin/shfmt ~/bin/shfmt
ln -s ~/bin/acpilight/xbacklight ~/bin/xbacklight
ln -s ~/bin/Hubstaff/HubstaffClient.bin.x86_64 ~/bin/hubstaff
ln -s ~/bin/styleguide/cpplint/cpplint.py ~/bin/cpplint.py
ln -s ~/bin/n-dir/n ~/bin/n
