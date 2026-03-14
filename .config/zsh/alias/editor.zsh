#!/bin/zsh

if [ -n "${EDITOR}" ] ; then
    EDITOR=$(readlink -e "${EDITOR}")
else
    EDITOR=$(z-alt-find 'vim.basic|vim.nox|vim.tiny|vim|mcedit|nano')
fi
if [ -n "${EDITOR}" ] ; then
    export EDITOR
    z-alt-set-static e "${EDITOR}"
    alias e='e '
else
    unset EDITOR
fi
