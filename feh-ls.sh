#!/bin/bash
#If no argument is given, just start feh
if [ -z "${1}" ]; then
  feh
  exit
fi

#Set different seperator to avoid problems with spaces
IFS='
'

FPATH="$1"
FNAME="$(basename "$FPATH")"
DPATH="$(dirname "$FPATH")"
#If just filename and no path is given, assume that it's in current directory
if [[ -z $DPATH  ]]; then
  DPATH="."
  FPATH="./$FNAME"
fi

feh -d -F -B black --action1 '~/bin/feh-cpg.sh %F &' -S filename --scale-down --auto-zoom --start-at "$FPATH" "$DPATH"
