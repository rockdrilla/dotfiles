#!/bin/zsh

z-alt-grep() {
    local -a a
    local n

    a=( ${(@s:|:)1} )
    [ ${#a} = 0 ] && a=( "$1" )
    n=${#a}
    [ -z "$1" ] && n=0
    case "$n" in
    0 ) ;;
    * )
        z-alt-set-static \
          "grep|-q -e ' ' ${ZSHU[d_conf]}/_.zsh" \
          "$1" \
          "GREP_OPTIONS='' command" \
    ;;
    esac
}

## TODO: add --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}
GREP_GNU='--color=auto'

z-alt-grep "grep ${GREP_GNU}|grep"
unset -f z-alt-grep
unset GREP_GNU

alias grep='grep '
alias egrep='grep -E '
alias fgrep='grep -F '
