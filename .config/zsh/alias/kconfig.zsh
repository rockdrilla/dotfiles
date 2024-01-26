#!/bin/zsh

kconf-set() {
    [ -n "${1:?}" ] || return 1

    local n=$1 v=$2
    shift 2

    [ $# -gt 0 ] || return 2

    command grep -ElZ "^((CONFIG_)?$n=|# (CONFIG_)?$n is not set)" "$@" \
    | xargs -0 -r sed -i -E -e "s/^(((CONFIG_)?$n)=.+|# ((CONFIG_)?$n) is not set)\$/\\2\\4=$v/"
}

kconf-unset() {
    [ -n "${1:?}" ] || return 1

    local n=$1
    shift

    [ $# -gt 0 ] || return 2

    command grep -ElZ "^(CONFIG_)?$n=" "$@" \
    | xargs -0 -r sed -i -E -e "s/^((CONFIG_)?$n)=.+\$/# \\1 is not set/"
}
