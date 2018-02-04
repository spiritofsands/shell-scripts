#!/bin/bash

old="$@"
new="$(dirname "$old")/! $(basename "$old")"
echo "$new"

cp "$old" "$new"
gimp "$new"
