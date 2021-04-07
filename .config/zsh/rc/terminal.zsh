#!/bin/zsh

function {
    [ "${ZSHU_RUN[nested]}" = 1 ] || return

    local -a a
    local x
    for i ( ${ZSHU_PARENTS_PID} ) ; do
        [ -r /proc/$i/environ ] || continue
        x=$(tr '\0' '\n' < /proc/$i/environ | sed -En '/^TERM=(.+)$/{s//\1/;p;}')
        [ -n "$x" ] || continue
        a+=( "$x" )
    done
    export ORIG_TERM="${a[-1]}"
    echo "${TERM}" | grep -Fq "${ORIG_TERM}" && return

    export TERM="${TERM}.${ORIG_TERM}"
}
