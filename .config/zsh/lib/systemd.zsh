#!/bin/zsh

z-systemctl() {
    [ "${ZSHU_RUN[systemd]}" = 1 ] || return 1
    systemctl --no-pager --no-ask-password "$@"
}

z-systemctl-quiet() {
    z-systemctl --quiet "$@" </dev/null &>/dev/null
}

z-systemctl-status-rc() {
    z-systemctl-quiet --lines=0 status "$@"
}

z-systemctl-exists() {
    [ "${ZSHU_RUN[systemd]}" = 1 ] || return 1
    z-systemctl-status-rc "$@"
    case "$?" in
    0 | 1 | 3 ) return 0 ;;
    ## also 4 = "no such unit"
    * ) return 1 ;;
    esac
}

z-systemctl-get() {
    [ -n "$1" ] || return 1
    [ -n "$2" ] || return 1
    local u p
    u="$1" ; p="$2" ; shift 2
    z-systemctl "$@" show "--property=$p" "$u"
}

z-systemctl-get-pid() {
    [ -n "$1" ] || return 1
    local u _pid
    u="$1" ; shift
    _pid=$(z-systemctl-get "$u" MainPID "$@" | cut -d= -f2-) || return 1
    [ -n "${_pid}" ] || return 1
    [ "${_pid}" != 0 ] || return 1
    z-proc-exists "${_pid}" || return 1

    echo "${_pid}"
}

## output is like:
##  Stream /run/rpcbind.sock
##  Stream 0.0.0.0:111
##  Datagram 0.0.0.0:111
##  Stream [::]:111
##  Datagram [::]:111
##  Netlink route 1361
z-systemctl-get-listen() {
    [ -n "$1" ] || return 1
    local u
    u="$1" ; shift

    z-systemctl "$@" show "$u" \
    | sed -En \
      -e '/^Listen=(.+) \((.+)\)$/s//\2 \1/p' \
      -e '/^Listen([^=]+)=(.*)$/s//\1 \2/p'
}

typeset -g -A ZSHU_RUN

ZSHU_RUN[systemd]=1
z-systemctl-quiet show-environment || ZSHU_RUN[systemd]=0
