#!/bin/bash

last_one="$1"

if [[ -z "$last_one" ]]; then
    last_one="$(docker ps | sed -n 2p)"
    last_one="${last_one%% *}"
fi

echo "Connecting to $last_one"
docker exec -it "$last_one" bash
