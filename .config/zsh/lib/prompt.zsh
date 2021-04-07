#!/bin/zsh

typeset -gA ZSHU_PM ZSHU_PS

ZSHU_PM[rst]='%b%k%u%s%f'
ZSHU_PM[crlf]=$'\n'

ZSHU_PM[status]='▪'
ZSHU_PS[lastcmd]="%B%(?.%F{green}.%F{red})${ZSHU_PM[status]}%f%b"

ZSHU_PS[pwd_std]='%F{cyan}%B%~%f%b'

ZSHU_PM[cmd_user]='%K{white}$'
ZSHU_PM[cmd_root]='%K{red}#'
ZSHU_PS[cmd]="%F{black}%(!.${ZSHU_PM[cmd_root]}.${ZSHU_PM[cmd_user]})${ZSHU_PM[rst]} "

ZSHU_PM[user]='%(!.%F{magenta}.%F{green})%n%f'
ZSHU_PM[host]="%B%(!.%F{red}.%F{blue})${ZSHU[host]}%f%b"

if autoload -Uz add-zsh-hook ; then

__z_pwd() {
    local p=${(%):-%~}
    [[ "$p" =~ '/.+' ]] || return
    local pfx="${p:h}"
    pfx="${pfx%%/}"
    local last="${p:t}"
    ZSHU_PS[pwd]="%F{cyan}${pfx}/%B${last}%f%b"
}

# ZSHU[pwd_hook]=''
__z_pwd_hook() {
    unset "ZSHU_PS[pwd]"
    for i ( ${(s: :)ZSHU[pwd_hook]} __z_pwd ) ; do
        "$i"
        (( ${+ZSHU_PS[pwd]} )) && return
    done
}

add-zsh-hook precmd __z_pwd_hook

else
    echo "shiny pwd's are disabled due to missing hook support" 1>&2
fi
