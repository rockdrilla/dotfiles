#!/bin/zsh

typeset -g -A ZSHU_PS1

## three-line prompt
function {
    local -a line

    line+="${ZSHU_PM[rst]}"
    line+="%B%F{black}┌[%b"
    line+="%F{yellow}%D{%y.%m.%d} %B%D{%H:%M:%S}%f%b"
    line+="%B%F{black}|%b"
    line+='${ZSHU_PM[id]:+"%B%F{white}${ZSHU_PM[id]}${ZSHU_PM[rst]}%B%F{black}|%b%f"}'
    line+="${ZSHU_PM[user]}%F{white}@${ZSHU_PM[host]}"
    line+='${ZSHU_PS[elapsed]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}┝%f%b "
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}└[%f%b"
    line+="${ZSHU_PS[lastcmd]}"
    line+='${ZSHU_PS[shlvl]}'
    line+="%B%F{black}|%b%f"
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS1[3L]="${(j::)line}"
}

## two-line prompt
function {
    local -a line

    line+="${ZSHU_PM[rst]}"
    line+="%B%F{black}┌[%b"
    line+='${ZSHU_PM[id]:+"%B%F{white}${ZSHU_PM[id]}${ZSHU_PM[rst]}%B%F{black}|%b%f"}'
    line+="${ZSHU_PM[user]}%F{white}@${ZSHU_PM[host]}"
    line+="%B%F{black}|%b"
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+='${ZSHU_PS[elapsed]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}└[%f%b"
    line+="${ZSHU_PS[lastcmd]}"
    line+='${ZSHU_PS[shlvl]}'
    line+="%B%F{black}|%b%f"
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS1[2L]="${(j::)line}"
}

## one-line prompt
function {
    local -a line

    line+="${ZSHU_PM[rst]}"
    line+="${ZSHU_PS[lastcmd]}"
    line+='${ZSHU_PS[shlvl]}'
    line+="%B%F{black}|%b"
    line+="${ZSHU_PM[user]}"
    line+="%B%F{black}|%b"
    line+='${ZSHU_PM[id]:+"%B%F{white}${ZSHU_PM[id]}${ZSHU_PM[rst]}%B%F{black}|%b%f"}'
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+='${ZSHU_PS[elapsed]}'
    line+="%B%F{black}|%b"
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS1[1L]="${(j::)line}"
}

z-ps1() {
    [ -n "$1" ] || {
        echo "${ZSHU_PS[ps1]}"
        return
    }

    local k ; k=$1
    case "$k" in
    [1-9] )
        (( ${+ZSHU_PS1[$k]} )) || k="${k}L"
    ;;
    [1-9][Ll] )
        (( ${+ZSHU_PS1[$k]} )) || k="${k%?}L"
    ;;
    esac
    (( ${+ZSHU_PS1[$k]} )) || return 1

    ZSHU_PS[ps1]=$k
    PS1=${ZSHU_PS1[$k]}
}

if [ "${ZSHU_RUN[nested1L]}" = 1 ] ; then
    z-ps1 1
elif [ "${ZSHU_RUN[nested]}" = 1 ] ; then
    z-ps1 2
else
    z-ps1 3
fi
