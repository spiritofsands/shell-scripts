#!/bin/bash

user="${1?}"
host="${2?}"
port="${3?}"
app="${4?}"
xpra start "ssh/${user}@${host}:${port}" --ssh='ssh -i .ssh/id_rsa' \
    "--start-child=${app}"
