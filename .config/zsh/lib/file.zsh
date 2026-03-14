#!/bin/zsh

z-is-text-file() {
    [ -n "$1" ] || return 1
    [ -f "$1" ] || return 1
    [ -s "$1" ] || return 1
    grep -IEq -e . "$1" || return 1
}
