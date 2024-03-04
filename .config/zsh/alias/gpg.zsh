#!/bin/zsh

gpg-warmup() {
    (( ${+commands[gpg]} )) || return 127

    local t r

    t=$(mktemp)
    command gpg -abs "$t"
    r=$?
    rm -f "$t" "$t.asc"

    return "$r"
}
