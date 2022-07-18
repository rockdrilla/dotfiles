#!/bin/zsh

z-time() {
    local a b elapsed result

    a=${EPOCHREALTIME}
    "$@"
    result=$?
    b=$(( EPOCHREALTIME - a ))
    elapsed=$(z-ts-to-human "$b" 6)
    echo 1>&2
    echo "time took: ${elapsed}" 1>&2

    return ${result}
}

if autoload -Uz add-zsh-hook ; then

typeset -gA ZSHU_PS
ZSHU_PS[cmd_threshold]=3

__z_cmdtime_precmd() {
    local t x elapsed

    t=${EPOCHREALTIME}
#   t=${(%):-%D{%s.%9.}}

    ZSHU_PS[elapsed]=''
    (( ${+ZSHU_PS[cmd_ts]} )) || return

    t=$(( t - ${ZSHU_PS[cmd_ts]} ))
    unset "ZSHU_PS[cmd_ts]"

    x=$(( ${ZSHU_PS[cmd_threshold]} + 0 ))
    [ "$x" = '0' ] && return

    x=$(( t - x ))
    [ "${x:0:1}" = '-' ] && return

    elapsed=$(z-ts-to-human "$t")
    ZSHU_PS[elapsed]=" %f[%B%F{yellow}+${elapsed}%b%f] "
}

__z_cmdtime_preexec() {
    ZSHU_PS[cmd_ts]=${EPOCHREALTIME}
#   ZSHU_PS[cmd_ts]=${(%):-%D{%s.%9.}}
}

add-zsh-hook precmd  __z_cmdtime_precmd
add-zsh-hook preexec __z_cmdtime_preexec

else
    echo "cmd time measurement is disabled due to missing hook support" 1>&2
fi
