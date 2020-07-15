#!/bin/bash

echo 'APT upgrade'
sudo apt update
sudo apt full-upgrade
sudo apt autoremove

echo
echo 'PIP upgrade'
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U

echo
echo 'NPM upgrade [disabled]'
# npm update

echo
echo 'VIM plugins upgrade'
(
    for dir in ~/.vim/plugged/*; do
        echo
        echo "$dir"
        cd "$dir" || return
        git fetch &>/dev/null
        git pull
    done
)

echo
echo 'TMUX plugins upgrade'
(
    for dir in ~/.tmux/plugins/*; do
        echo
        echo "$dir"
        cd "$dir" || return
        git fetch &>/dev/null
        git pull
    done
)
