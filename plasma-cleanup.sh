#!/bin/bash

unchmod_list=(
/usr/bin/gmenudbusmenuproxy
/usr/bin/kaccess
)

for item in "${unchmod_list[@]}"; do
    sudo chmod -x "$item"
done
