#!/bin/bash

volume() {
    amixer -M -D pulse get "${1?}" | grep -oE '.[[:digit:]]+%.*$' -m 1 | tr -d '[]'
}

case "${1?}" in
    --volume)
        volume 'Master'
        ;;
    --microphone)
        volume 'Capture'
        ;;
esac
