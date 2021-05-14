#!/bin/bash

usage() {
    echo "$0 --volume|--microphone"
    exit 0
}

volume() {
    amixer -M -D pulse get "${1?}" | grep -oE '.[[:digit:]]+%.*$' -m 1 | tr -d '[]'
}

if [[ -z "${1}" ]]; then
    usage
fi
case "${1?}" in
    --volume)
        volume 'Master'
        ;;
    --microphone)
        volume 'Capture'
        ;;
esac
