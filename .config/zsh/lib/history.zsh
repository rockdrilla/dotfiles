#!/bin/zsh

z-history() {
    local list
    zparseopts -E l=list
    if [[ -n "$list" ]]; then
        builtin fc "$@"
    else
        [[ ${@[-1]-} = *[0-9]* ]] && builtin fc -il "$@" || builtin fc -il "$@" 1
    fi
}
