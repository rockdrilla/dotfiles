#!/bin/zsh

typeset -Ua zshu_modules
zshu_modules+=(
    complete
    complist
    computil
    langinfo
    main
    parameter
    stat
    terminfo
    zle
    zutil
)
for i ( ${zshu_modules} ) ; do
    [[ "$i" != */* ]] && i="zsh/$i"
    zmodload -i $i
done ; unset i
unset zshu_modules

autoload -Uz +X colors && colors
