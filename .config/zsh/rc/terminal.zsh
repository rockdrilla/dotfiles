#!/bin/zsh

z-orig-term() {
    local -a a
    local i x

    for i ( ${ZSHU_PARENTS_PID} ) ; do
        i="${ZSHU[procfs]}/$i/environ"
        [ -r "$i" ] || continue
        x=$(sed -zEn '/^TERM=(.+)$/{s//\1/;p;}' "$i" 2>/dev/null | tr -d '\0')
        [ -n "$x" ] || continue
        a+=( "$x" )
    done
    case "$1" in
    \* | @ )
        local ORIG_TERM=( $a )
        declare -p ORIG_TERM
    ;;
    * )
        i='-1' ; x="${1:-$i}"
        echo "${a[$x]}"
    ;;
    esac
}
