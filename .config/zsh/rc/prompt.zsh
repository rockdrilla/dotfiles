#!/bin/zsh

# z-starship-init

## three-line prompt
function {
    local -a line

    line+="${ZSHU_PM[rst]}"
    line+="%B%F{black}┌[%b"
    line+="%F{yellow}%D{%y.%m.%d} %B%D{%H:%M:%S}%f%b"
    line+="%B%F{black}|%b"
    line+="${ZSHU_PM[user]}%F{white}@${ZSHU_PM[host]}"
    line+='${ZSHU_PS[elapsed]}'
    line+='${ZSHU_PS[status_extra]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}┝%f%b "
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}└[%f%b"
    line+="${ZSHU_PS[lastcmd]}"
    line+="%B%F{black}|%b%f"
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS[ps1_3L]="${(j::)line}"
}

## two-line prompt
function {
    local -a line
    local r

    line+="${ZSHU_PM[rst]}"
    line+="%B%F{black}┌[%b"
    line+="${ZSHU_PM[user]}%F{white}@${ZSHU_PM[host]}"
    line+="%B%F{black}|%b"
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+='${ZSHU_PS[elapsed]}'
    line+="${ZSHU_PM[rst]}"

    line+="${ZSHU_PM[crlf]}"

    line+="%B%F{black}└[%f%b"
    line+="${ZSHU_PS[lastcmd]}"
    line+="%B%F{black}|%b%f"
    line+='${ZSHU_PS[status_extra]}'
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS[ps1_2L]="${(j::)line}"
}

## one-line prompt
function {
    local -a line

    line+="${ZSHU_PM[rst]}"
    line+="${ZSHU_PS[lastcmd]}"
    line+="%B%F{black}|%b"
    line+="${ZSHU_PM[user]}"
    line+="%B%F{black}|%b"
    line+='${ZSHU_PS[pwd]:-${ZSHU_PS[pwd_std]}}'
    line+='${ZSHU_PS[pwd_extra]}'
    line+='${ZSHU_PS[elapsed]}'
    line+="%B%F{black}|%b"
    line+="${ZSHU_PS[cmd]}"

    ZSHU_PS[ps1_1L]="${(j::)line}"
}

ZSHU_PS[ps1_standard]=${ZSHU_PS[ps1_3L]}
ZSHU_PS[ps1_nested]=${ZSHU_PS[ps1_2L]}

if [ "${ZSHU_RUN[nested]}" = 0 ]
then PS1=${ZSHU_PS[ps1_standard]}
else PS1=${ZSHU_PS[ps1_nested]}
fi
