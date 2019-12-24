#!/bin/bash

get_num() {
  num="${s%:*}"
  echo "${num#$}"
}

get_name() {
  echo "${1#*:}"
}

IFS=' 
'
CURRENT="${1?}"

sessions=( $(tmux list-sessions -F '#{s/$//:session_id}:#{session_name}') )
for s in "${sessions[@]}"; do
  name="$(get_name "$s")"
  num="$(get_num "$s")"

  if [[ "$(get_name "$s")" == "$(get_name "$CURRENT")" ]]; then
    echo -n "#[bg=colour54] $((num+1)):$name #[bg=default]"
  else
    echo -n " $((num+1)):$name "
  fi
done
