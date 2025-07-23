#!/bin/zsh

## early load modules
zmodload zsh/mathfunc zsh/datetime zsh/zprof

typeset -gA ZSHU

__z_unsupported() { echo "not supported" >&2 ; }

ZSHU[t_begin]=${(%):-%D{%s.%6.}}

ZSHU[d_zdot]="${ZDOTDIR}"
ZSHU[d_dotfiles]="${ZDOTDIR}/.config/dotfiles"
ZSHU[d_conf]="${ZDOTDIR}/.config/zsh"
ZSHU[d_cache]="${ZDOTDIR}/.cache/zsh"

ZSHU[d_var]="${ZSHU[d_conf]}/var"
ZSHU[d_bin]="${ZSHU[d_dotfiles]}/bin"
ZSHU[d_scripts]="${ZSHU[d_dotfiles]}/scripts"

## early escape
unsetopt global_rcs

## safety measure:
## redirect all following activity within ZDOTDIR to cache
export ZDOTDIR="${ZDOTDIR}/.config/zsh.dots"

## cleanup: start from scratch
for i ( a s f d ) ; do unhash -$i -m '*' ; done ; unset i

## set default umask
umask 0022

zshu_parts=( env opt lib rc alias local )

for n ( ${zshu_parts} ) ; do
    [ -s "${ZSHU[d_conf]}/$n.zsh" ] || continue
    source "${ZSHU[d_conf]}/$n.zsh"
done ; unset n

for n ( ${zshu_parts} ) ; do
    [ -d "${ZSHU[d_conf]}/$n" ] || continue
    for i ( "${ZSHU[d_conf]}/$n"/*.zsh(N.r) ) ; do
        source "$i"
    done
done ; unset i n

unset zshu_parts

hash -f

t=${(%):-%D{%s.%6.}}
t=$[ t - ZSHU[t_begin] ]
unset 'ZSHU[t_begin]'
n=${t#*.}
ZSHU[t_load]=${t%.*}.${n:0:4}
unset n t
