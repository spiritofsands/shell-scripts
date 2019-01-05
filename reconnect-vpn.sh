#!/bin/bash

while true; do
    if ! nmcli connection show --active | grep -q vpn; then
        notify-send 'VPN' 'Reconnecting...'

        nmcli connection up "$(nmcli connection show | grep vpn | sed 's/ .*//')"
    fi

    sleep 30
done
