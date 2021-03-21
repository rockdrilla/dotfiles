#!/bin/zsh

z-alt-grep() {
    local -a a
    a=( ${(@s:|:)1} )
    [ ${#a} = 0 ] && a=( "$1" )
    local n=${#a}
    [ -z "$1" ] && n=0
    case "$n" in
    0) : do nothing ;;
    *) z-alt-set-static "grep|-q -e ' ' ${ZSHU[d_zdot]}/.zshenv" "$1" "GREP_OPTIONS='' " ;;
    esac
}

## TODO: add --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}
GREP_GNU='--color=auto'

z-alt-grep "grep ${GREP_GNU}|grep"

unfunction z-alt-grep
unset GREP_GNU

egrep() { grep -E "$@" ; }
fgrep() { grep -F "$@" ; }
