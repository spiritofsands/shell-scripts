#
# Extended cd ..
#

# Configuration:
# Put into bashrc:
# source "path/to/extended_cd.bash"

# Usage:
# PWD is /a/b/c/d/e/f/g
# cd.. 5
# PWD is /a/b/c
#
# PWD is /some/path/dir/another/one
# cd.. dir
# PWD is /some/path/dir

_change_dir() {
  case $1 in
    *[!0-9]*)
      cd "$( pwd | sed -r "s|(.*/$1[^/]*/).*|\1|" )" || return
      ;;                                               # if not found - not cd
    *)
      cd "$(printf "%0.0s../" $(seq 1 "$1" 2>/dev/null))" || return
      ;;
  esac
}

alias 'cd..'='_change_dir'
