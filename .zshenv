#!/bin/zsh
if [[ -o interactive ]] ; then
    ## early redirect
    : "${ZDOTDIR:=${HOME}}"
    [ "${ZDOTDIR}" = "${HOME}/.cache/zsh/dots" ] && ZDOTDIR="${HOME}"
    source "${ZDOTDIR}/.config/zsh/_.zsh"
fi
