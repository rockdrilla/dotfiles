#!/bin/zsh

z-time() {
    local a r

    a=${EPOCHREALTIME}
    "$@" ; r=$?
    a=$[ EPOCHREALTIME - a ]
    a=$(z-ts-to-human "$a" 6)
    printf '\n# time took: %s\n' "$a" >&2

    return $r
}

if autoload -Uz add-zsh-hook ; then

typeset -g -A ZSHU_PS
ZSHU_PS[cmd_threshold]=3

__z_cmdtime_measure() {
    local t x

    x=${EPOCHREALTIME}

    unset 'ZSHU[cmd_dt]' 'ZSHU_PS[elapsed]'
    (( ${+ZSHU[cmd_ts]} )) || return

    t=$[ x - ZSHU[cmd_ts] ]
    ZSHU[cmd_ts]=$x

    x=${ZSHU_PS[cmd_threshold]}
    x=$[ x + 0 ] || x=0
    [ "$x" = 0 ] && return

    x=$[ t - x ]
    [ "${x:0:1}" = '-' ] && return

    t=$(z-ts-to-human "$t")
    ZSHU[cmd_dt]=$t
    ZSHU_PS[elapsed]=" %f[%B%F{yellow}+$t%b%f]"
}

__z_cmdtime_set() {
    ZSHU[cmd_ts]=${EPOCHREALTIME}
}

add-zsh-hook precmd  __z_cmdtime_measure
add-zsh-hook preexec __z_cmdtime_set

else

echo "cmd time measurement is disabled due to missing hook support" >&2

fi
