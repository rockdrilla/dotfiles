#!/bin/zsh

typeset -Uga ZSHU_TERM_MISSING

z-ti-test() {
    local r i

    r=0
    for i ; do
        [ -z "$i" ] && continue
        if ! (( ${+terminfo[$i]} )) ; then
            ZSHU_TERM_MISSING+=( "$1" )
            r=1
        fi
    done

    return $r
}
