#!/bin/bash

while true; do
    if ! nmcli connection show --active | grep -q vpn; then
        notify-send 'VPN' 'Reconnecting...'

        if ! nmcli connection up "$(nmcli connection show | grep vpn | sed 's/ .*//')"; then
            echo 'nmcli failed'
            exit 1
        fi
    fi

    sleep 30
done
