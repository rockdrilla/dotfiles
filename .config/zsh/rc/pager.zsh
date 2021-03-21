#!/bin/zsh

PAGER=$(z-alt-find 'less|pager|more')
if [ -n "${PAGER}" ] ; then
    export PAGER
    READNULLCMD=$(which "${PAGER}" | xargs -r readlink -e)
else
    unset READNULLCMD
    unset NULLCMD
fi
