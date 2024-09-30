#!/bin/bash

# intended to be used with
# kde-inhibit --power spotify_no_exit.sh

/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=spotify --file-forwarding com.spotify.Client "$@"

while flatpak ps | grep -q spotify; do
    sleep 5s
done
