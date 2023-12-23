#!/bin/zsh
if [[ -o interactive ]] ; then
    ## early redirect
    : "${ZDOTDIR:=${HOME}}"
    source "${ZDOTDIR}/.config/zsh/_.zsh"
fi
