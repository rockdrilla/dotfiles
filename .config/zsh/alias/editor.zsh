#!/bin/zsh

while : ; do
    ## respect already defined EDITOR
    if [ -n "${EDITOR}" ] ; then
        EDITOR=$(which "${EDITOR}")
        if [ -n "${EDITOR}" ] ; then
            [ -x "${EDITOR}" ] || unset EDITOR
        fi
    fi
    [ -z "${EDITOR}" ] || break

    ## grab from ~/.selected_editor
    EDITOR=$(z-env-from-file SELECTED_EDITOR "${ZSHU[d_zdot]}/.selected_editor")
    if [ -n "${EDITOR}" ] ; then
        EDITOR=$(which "${EDITOR}")
        [ -x "${EDITOR}" ] || unset EDITOR
    fi
    [ -z "${EDITOR}" ] || break

    ## fallback to predefined list
    EDITOR=$(z-alt-find 'vim.basic|vim.nox|vim.tiny|vim|mcedit|nano')
    [ -n "${EDITOR}" ] || break
    [ -x "${EDITOR}" ] || unset EDITOR
break;done

if [ -n "${EDITOR}" ] ; then
    export EDITOR
    z-alt-set-static e "${EDITOR}"
    alias e='e '
else
    unset EDITOR
fi
