#!/bin/bash

# dmenu cannot display more than 30 lines, to avoid screen clutter. Only relevant if you have more than 30 windows open.
height=$(wmctrl -l | wc -l)
if [[ $height -gt 30 ]]
	then heightfit=30
	else heightfit=$height
fi


# | cut -c 13- | grep "^$(wmctrl -d | grep '\*' | cut -d ' ' -f1)" | cut -d' ' -f3-

i=0;
while read -r line; do
  id[$i]="${line%% *}"
  line="${line#*  }"
  desktop[$i]="${line%% *}"
  line="${line#* }"
  #host[$i]="${line%% *}"
  line="${line#* }"
  name[$i]="$line"

  ((i+=1))
done < <(wmctrl -l)

current_desktop="$(wmctrl -d | grep '\*' | cut -d ' ' -f1)"

current_indices=()
for ((j=0; j<i; j++)); do
  if [[ "${desktop[j]}" -eq "$current_desktop" ]]; then
    current_indices+=($j)
  fi
done

active_window="$( xprop -id "$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)" WM_NAME | awk -F '"' '{print $2}')"

current_names="$(for i in "${current_indices[@]}"; do
  if [[ "$active_window" != "${name[i]}" ]]; then
    echo "${name[i]}";
  fi
done)"

select_window() {
  local choice="$1"

  for i in "${current_indices[@]}"; do
    if [[ "$choice" == "${name[i]}" ]]; then
      wmctrl -iR "${id[i]}"
      exit 0
    fi
  done

  exit 1
}

if [[ "${#current_indices[@]}" -le 2 ]]; then # only 2 windows
  select_window "$current_names"
else
  current_names+=$'\n'"$active_window"

  choice="$(echo "$current_names" |
    dmenu -fn Terminus:size=14 -i -p 'Select window:' -l "$heightfit" -sb '#964b00')"

  select_window "$choice"
fi
