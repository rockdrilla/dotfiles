#!/bin/zsh

function {
    local -a a
    local x
    for i ( ${ZSHU_PARENTS_PID} ) ; do
        [ -r /proc/$i/environ ] || continue
        x=$(tr '\0' '\n' < /proc/$i/environ | sed -En '/^TERM=(.+)$/{s//\1/;p;}')
        [ -n "$x" ] || continue
        a+=( "$x" )
    done
    export ORIG_TERM="${a[-1]}"
}
