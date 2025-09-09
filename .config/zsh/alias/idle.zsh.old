#!/bin/zsh

idle() {
    [ -n "${1:?}" ]

    local f

    f=$(type "$1")
    case "$f" in
    "$1 is /"* )
        z-idle-ext "$@"
    ;;
    * )
        z-idle-int "$@"
    ;;
    esac
}

z-idle-ext() {
    [ -n "${1:?}" ]

    local -a s

    s+=( $(z-alt-find 'nice -n +40') )
    s+=( $(z-alt-find 'chrt -i 0'  ) )
    s+=( $(z-alt-find 'ionice -c 3') )
    command ${s[@]} "$@"
}

z-idle-int() {
    [ -n "${1:?}" ]

    ## execute in subshell
    (
        {
        command renice -n +40 -p ${sysparams[pid]}
        command chrt -i -p 0 ${sysparams[pid]}
        command ionice -c 3 -p ${sysparams[pid]}
        } </dev/null &>/dev/null
        "$@"
    )
}
