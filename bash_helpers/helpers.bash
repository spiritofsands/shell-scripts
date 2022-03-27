_is_installed() {
  command -v "${1?}" &> /dev/null
}

_is_ssh() {
    [[ -n "$SSH_CLIENT" || \
        -n "$SSH_TTY" || \
        $(ps -o comm= -p "$PPID") =~ .*sshd ]]
}

if _is_installed wine; then
    wine32() {
        WINEPREFIX=~/.wine WINEARCH=win32 wine "$@"
    }
fi

pycache_clean() {
    fd -I __pycache__ | xargs rm -rf
    fd -IH .pytest_cache | xargs rm -rf
}

alert() {
    notify-send --urgency=low -i \
        "$([ $? = 0 ] && echo terminal || echo error)" \
        "$(history | tail -n1 | sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}
