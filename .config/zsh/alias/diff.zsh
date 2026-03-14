#!/bin/zsh

if [ "${ZSHU[diff_color]}" = 1 ] ; then
    alias diff='diff --color=auto '
else
    alias diff='diff '
fi
