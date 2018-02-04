#!/bin/bash

print_session() {
  num="${1%:*}"
  name="${1#*:}"
  echo "$((num+1)):$name"
}

IFS=' 
'
sessions=( $(tmux list-sessions -F '#{s/$//:session_id}:#{session_name}') )
for s in ${sessions[@]}; do
  if [[ "$s" == "$1" ]]; then
    echo -n "#[bg=colour54] $(print_session $s) #[bg=default]"
  else
    echo -n " $(print_session $s) "
  fi
done
