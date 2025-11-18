#!/bin/zsh

typeset -a zshu_modules
zshu_modules=(
    clone
    langinfo
    mapfile
    parameter
    sched
    stat
    termcap
    terminfo
    watch
    zpty

    zle
    zleparameter
    deltochar
    complete
    complist
    computil
    zutil
    compctl
)
for i ( ${zshu_modules} ) ; do
    i="zsh/$i"
    zmodload "$i"
done
unset i zshu_modules

## fix for zsh/stat
disable stat >/dev/null 2>&1
zsh-stat() { zstat "$@"; }

autoload -Uz +X colors && colors
