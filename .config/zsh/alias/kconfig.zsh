#!/bin/zsh

kconf-set() {
    local n v

    n=$1 v=$2 ; shift 2
    grep -ElZ "^((CONFIG_)?$n=|# (CONFIG_)?$n is not set)" "$@" \
    | xargs -0 -r sed -i -E -e "s/^(((CONFIG_)?$n)=.+|# ((CONFIG_)?$n) is not set)\$/\\2\\4=$v/"
}

kconf-unset() {
    local n

    n=$1 ; shift
    grep -ElZ "^(CONFIG_)?$n=" "$@" \
    | xargs -0 -r sed -i -E -e "s/^((CONFIG_)?$n)=.+\$/# \\1 is not set/"
}
