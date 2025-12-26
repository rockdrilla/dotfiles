#!/bin/zsh

z-proc-exists() {
    [ -n "${1:?}" ]

    while [ -n "${ZSHU[procfs]}" ] ; do
        [ -d "${ZSHU[procfs]}" ] || return 1
        [ -f "${ZSHU[procfs]}/$1/status" ]
        return $?
    done

    ps -o 'pid=' -p "$1" &>/dev/null
}

z-proc-run-bg() {
    [ -n "${1:?}" ]

    z-have-cmd "$1" || return 127

    if (( ${+commands[setsid]} )) ; then
        setsid -f "$@" </dev/null &>/dev/null &|
        return
    fi

    "$@" </dev/null &>/dev/null &|
}
