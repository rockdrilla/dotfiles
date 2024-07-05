#!/bin/zsh

## alias -g ...='../..'
## alias -g ....='../../..'
## ...
for (( i=3 ; i < 10 ; i++ )) ; do
    alias -g ${(l:i::.:)}='..'${(l:3*(i-2)::/..:)}
done ; unset i

alias -- -='cd -'
alias 1='cd -'
## alias 2='cd -2'
## ...
for (( i=2 ; i < 10 ; i++ )) ; do
    alias $i="cd -$i"
done ; unset i

## "Go to Dir" - create path if missing
gd() {
    [ $# -lt 2 ] || echo "# gd() takes no more than one argument, seen instead: $#" >&2

    case "$#" in
    0 ) cd ;;
    * )
        if ! [ -d "$1" ] ; then
            mkdir -p "$1" || return $?
        fi
        cd "$1"
    ;;
    esac
}
