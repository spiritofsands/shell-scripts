#!/bin/bash

set -e

src_dir="$1/"
[[ -d "$src_dir" ]]

dest_dir="$2/"

rsync --archive --whole-file --no-checksum --no-compress "$src_dir" "$dest_dir"
