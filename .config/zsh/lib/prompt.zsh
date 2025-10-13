#!/bin/zsh

typeset -g -A ZSHU_PM ZSHU_PS

ZSHU_PM[rst]='%b%k%u%s%f'
ZSHU_PM[crlf]=$'\n'

ZSHU_PS[shlvl]='%(2L.%B%F{white}|%F{cyan}%L%b%f.)'

ZSHU_PM[status]='▪'
ZSHU_PS[lastcmd]="%B%(?.%F{green}.%F{red})${ZSHU_PM[status]}%f%b"

ZSHU_PS[pwd_std]='%F{cyan}%B%~%f%b'

ZSHU_PM[cmd_user]='%F{white}$'
ZSHU_PM[cmd_root]='%F{red}#'
ZSHU_PS[cmd]="%k%B%(!.${ZSHU_PM[cmd_root]}.${ZSHU_PM[cmd_user]})${ZSHU_PM[rst]} "

ZSHU_PM[user]='%(!.%F{magenta}.%F{green})%n%f'
ZSHU_PM[host]="%B%(!.%F{red}.%F{blue})${ZSHU[host]}%f%b"

if autoload -Uz add-zsh-hook ; then

__z_pwd() {
    local p pfx last

    p=${(%):-%~}
    [[ "$p" =~ '/.+' ]] || return
    pfx="${p:h}"
    pfx="${pfx%%/}"
    last="${p:t}"
    ZSHU_PS[pwd]="%F{cyan}${pfx}/%B${last}%f%b"
}

# ZSHU[pwd_hook]=''
__z_pwd_hook() {
    local i

    unset 'ZSHU_PS[pwd]'
    for i ( ${(s: :)ZSHU[pwd_hook]} __z_pwd ) ; do
        unset 'ZSHU_PS[pwd_extra]'
        "$i"
        (( ${+ZSHU_PS[pwd]} )) && return
    done
}

add-zsh-hook precmd __z_pwd_hook

else

echo "shiny pwd's are disabled due to missing hook support" >&2

fi
