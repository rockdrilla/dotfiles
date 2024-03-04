#!/bin/zsh

z-systemctl() {
    command systemctl --quiet --no-pager --lines=0 --no-ask-password "$@"
}

z-systemctl-status-rc() {
    z-systemctl status "$@" >/dev/null 2>&1
}

z-systemctl-exists() {
    z-systemctl-status-rc "$@"
    case "$?" in
    0 | 1 | 3 ) return 0 ;;
    ## also 4 = "no such unit"
    * ) return 1 ;;
    esac
}
