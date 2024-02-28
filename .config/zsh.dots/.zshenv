#!/bin/zsh
if [[ -o interactive ]] ; then
    ## early redirect
    ZDOTDIR="${ZDOTDIR%/${ZDOTDIR:t2}}"
    source "${ZDOTDIR}/.zshenv"
fi
