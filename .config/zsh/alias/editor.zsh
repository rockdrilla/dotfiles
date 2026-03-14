#!/bin/zsh

EDITOR=$(z-alt-find 'e|vim.basic|vim.nox|vim.tiny|vim|mcedit|nano')
if [ -n "${EDITOR}" ] ; then
    export EDITOR
    z-alt-set-static e "${EDITOR}"
    alias e="command ${EDITOR:t} "
else
    unset EDITOR
fi
