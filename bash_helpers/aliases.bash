_cwd="$(dirname "${BASH_SOURCE[0]}")"
source "$_cwd/helpers.bash"
source "$_cwd/extended_cd.bash"
source "$_cwd/short_git.bash"
source "$_cwd/etc/helpers.bash"

if [ -x /usr/bin/dircolors ]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi

  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

# exit alias
alias ':q'='exit'

alias fd=fdfind
