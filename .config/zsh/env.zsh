#!/bin/zsh

## sort-n-fill PATH
function {
    local -a p=( $path )
    local -aU t npath games

    ## strip "games" first :)
    t=( ${(@)p:#*games*} )
    games+=( ${(@)p:|t} )
    p=( $t )

    ## process in-home part
    t=( ${(@)p:#${HOME}/*} )
    npath+=( "${ZSHU[d_bin]}" "${HOME}/bin" )
    npath+=( ${(@)p:|t} )
    p=( $t )

    ## process /usr/local/*
    t=( ${(@)p:#/usr/local/*} )
    npath+=( /usr/local/sbin /usr/local/bin )
    npath+=( ${(@)p:|t} )
    p=( $t )

    ## process /usr/*
    t=( ${(@)p:#/usr/*} )
    npath+=( /usr/sbin /usr/bin )
    npath+=( ${(@)p:|t} )
    p=( $t )

    ## now we're with /sbin and /bin... probably :)
    npath+=( /sbin /bin )
    npath+=( $p )

    ## finally... games! xD
    npath+=( /usr/local/games /usr/games )
    npath+=( $games )

    path=( $npath )
    hash -f
}

unset GREP_OPTIONS
unset LS_OPTIONS

unset LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
unset LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION
export LANG=C.UTF8
export LC_ALL=C.UTF-8

z-set-tmpdir() {
    TMPDIR="$1"
    TMP="$1"
    TEMPDIR="$1"
    TEMP="$1"
    export TMPDIR TMP TEMPDIR TEMP
}
z-set-tmpdir "${TMPDIR:=/tmp}"

ZSHU[uname]=$(uname -s 2>/dev/null)
ZSHU[uname]=${ZSHU[uname]:l}

ZSHU[mach]=$(uname -m 2>/dev/null)
ZSHU[mach]=${ZSHU[mach]:l}
case "${ZSHU[mach]}" in
amd64) ZSHU[mach]=x86_64 ;;
arm64) ZSHU[mach]=aarch64 ;;
armv*) ZSHU[mach]=arm ;;
esac

ZSHU[os_type]=${OSTYPE:l}

ZSHU[os_family]=${ZSHU[uname]:l}
case "${ZSHU[os_family]}" in
*bsd) ZSHU[os_family]=bsd ;;
esac

ZSHU[host_name]=${(%):-%m}
ZSHU[host_fqdn]=${(%):-%M}
ZSHU[host]=${ZSHU[host_name]}
function {
    [ "${ZSHU[uname]}" = darwin ] || return
    ZSHU[host]=$(scutil --get ComputerName 2>/dev/null) && return
    ## last resort
    ZSHU[host]=${ZSHU[host_name]}
}