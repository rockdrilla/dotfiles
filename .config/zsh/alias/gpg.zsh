#!/bin/zsh

gpg-warmup() {
    local t r

    (( ${+commands[gpg]} )) || return 1

    t=$(mktemp)
    command gpg -abs "$t"
    r=$?
    command rm -f "$t" "$t.asc"

    return "$r"
}
