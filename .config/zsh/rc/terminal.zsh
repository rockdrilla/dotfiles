#!/bin/zsh

function {
    local -a a
    local i x

    for i ( ${ZSHU_PARENTS_PID} ) ; do
        [ -r "/proc/$i/environ" ] || continue
        x=$(sed -zEn '/^TERM=(.+)$/{s//\1/;p;}' "/proc/$i/environ" 2>/dev/null)
        [ -n "$x" ] || continue
        a+=( "$x" )
    done
    export ORIG_TERM="${a[-1]}"
}
