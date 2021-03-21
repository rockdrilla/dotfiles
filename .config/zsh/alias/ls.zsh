#!/bin/zsh

if [ -z "${LS_COLORS}" ] ; then
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
fi

case "${ZSHU[os_family]}" in
bsd|darwin) export LSCOLORS="Gxfxcxdxbxegedabagacad" ;;
esac

__z_alt_ls() {
    local -a a
    a=( ${(@s:|:)1} )
    [ ${#a} = 0 ] && a=( "$1" )
    local n=${#a}
    [ -z "$1" ] && n=0
    case "$n" in
    0) : do nothing ;;
    *) z-alt-set-static 'ls|-d .' "$1" "LS_OPTIONS='' " ;;
    # 1) z-alt-set-static  'ls|-d .' "$1" "LS_OPTIONS='' " ;;
    # *) z-alt-set-dynamic 'ls|-d .' "$1" "LS_OPTIONS='' " ;;
    esac
}

LS_GNU='--color=tty --group-directories-first'

case "${ZSHU[os_type]}" in
linux*)    alt="ls ${LS_GNU}|ls" ;;
netbsd*)   alt="gls ${LS_GNU}|ls" ;;
openbsd*)  alt="gls ${LS_GNU}|colorls -G|ls" ;;
freebsd*)  alt="gls ${LS_GNU}|ls -G|ls" ;;
darwin*)   alt="gls ${LS_GNU}|ls -G|ls" ;;
*)         alt="ls ${LS_GNU}|ls" ;;
esac

__z_alt_ls "${alt}"

unfunction __z_alt_ls
unset alt LS_GNU

[ -n "${LS_COLORS}" ] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

case "${ZSHU[os_family]}" in
linux) alias l='ls -lhF ' ;;
bsd)   alias l='ls -lhIF ' ;;
esac

alias ll='ls -lAF '

case "${ZSHU[os_family]}" in
linux) alias lll='ls -lAn --full-time ' ;;
bsd)   alias lll='ls -lAnT ' ;;
esac
