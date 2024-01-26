#!/bin/zsh

: "${ZDOTDIR:=${HOME}}"

typeset -gA ZSHU

ZSHU[t_begin]=${(%):-%D{%s.%6.}}

ZSHU[d_zdot]="${ZDOTDIR}"
ZSHU[d_cache]="${ZDOTDIR}/.cache/zsh"
ZSHU[d_conf]="${ZDOTDIR}/.config/zsh"

ZSHU[d_var]="${ZSHU[d_conf]}/var"

ZSHU[d_bin]="${ZDOTDIR}/.config/dotfiles/bin"
ZSHU[d_scripts]="${ZDOTDIR}/.config/dotfiles/scripts"

for i ( d_zdot d_cache d_conf d_bin d_scripts d_var ) ; do
    d=${ZSHU[$i]}
    [ -d "$d" ] || mkdir -p "$d"
done ; unset i d

## early escape
unsetopt global_rcs

## safety measure:
## redirect all following activity within ZDOTDIR to cache
## (probably) these files are safe to remove
ZDOTDIR="${ZSHU[d_cache]}"
rm -f "${ZDOTDIR}/.zshrc" "${ZDOTDIR}/.zlogin"

## cleanup: start from scratch
for i ( a s f d ) ; do unhash -$i -m '*' ; done ; unset i

## set default umask
umask 0022

zshu_parts=( env opt lib rc alias local )

for n ( ${zshu_parts} ) ; do
    f="${ZSHU[d_conf]}/$n.zsh"
    [ -s "$f" ] && source "$f"
done ; unset n f

for n ( ${zshu_parts} ) ; do
    d="${ZSHU[d_conf]}/$n"
    [ -d "$d" ] || continue
    for i ( $d/*.zsh(N.r) ) ; do
        source "$i"
    done ; unset i
done ; unset n d

unset zshu_parts

ZSHU[t_end]=${(%):-%D{%s.%6.}}

ZSHU[t_load]=$[ ZSHU[t_end] - ZSHU[t_begin] ]
ZSHU[t_load]=${ZSHU[t_load]:0:6}

unset 'ZSHU[t_begin]' 'ZSHU[t_end]'
