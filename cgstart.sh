#!/bin/bash

die() {
  echo "$@"
  exit 1
}

parse_limit() {
  local str="$1"
  local size=0
  local multiply=0

  printf -v size '%d\n' "$str" 2>/dev/null

  [[ "$size" -eq 0 ]] && die 'Wrong size'

  case "$str" in
    *gb)
      multiply="$((1024*1024*1024))"
      ;;
    *mb)
      multiply="$((1024*1024))"
      ;;
    *)
      die 'Wrong size'
      ;;
  esac

  limit="$((size * multiply))"
}



[[ -z "$2" ]] && die "Usage: $0 firefox 1gb"

which cgexec &>/dev/null || die 'No cgexec'
which cgcreate &>/dev/null || die 'No cgcreate'

name="$1"
parse_limit "$2"
path="$(which "$name" 2>/dev/null)"
[[ -z "$path" ]] && die "No such program: $name"



if [[ ! -d "/sys/fs/cgroup/memory/$name" ]]; then
  echo 'Registering a new group'
  echo "sudo cgcreate -g memory:/$name"
  sudo cgcreate -g "memory:/$name" || die 'Failed'
fi


current_limit="$(cat "/sys/fs/cgroup/memory/$name/memory.limit_in_bytes")"
if [[ "$current_limit" -ne "limit" ]]; then
  echo -n 'Writing the limit: '
  echo "$limit" | sudo tee "/sys/fs/cgroup/memory/$name/memory.limit_in_bytes" || die 'Failed'
fi

user="$(whoami)"
echo "sudo cgexec -g memory:$name sudo -u $user $path &>/dev/null"
sudo cgexec -g "memory:$name" sudo -u "$user" "$path" &>/dev/null || die 'Failed'
