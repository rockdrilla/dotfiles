#!/bin/zsh

gpg-warmup() {
    (( ${+commands[gpg]} )) || return 1
    local r t
    t=$(mktemp)
    gpg --expert -abs "$t"
    r=$?
    command rm -f "$t" "$t.asc"
    return "$r"
}
