#!/bin/zsh

z-env() {
    [ -n "$1" ] || return 1
    sed -En "\\${ZSHU_XSED}^$1=([\"']?)(.*)\\1\$${ZSHU_XSED}{s//\\2/;p;q}"
}

z-env-from-file() {
    [ -n "$1" ] || return 1
    [ -n "$2" ] || return 2
    [ -f "$2" ] || return 3

    z-env "$1" < "$2"
}
