#!/bin/zsh

PAGER=$(z-alt-find 'less|pager|more')
if [ -n "${PAGER}" ] ; then
    export PAGER
    READNULLCMD=${PAGER}
else
    unset PAGER READNULLCMD NULLCMD
fi
