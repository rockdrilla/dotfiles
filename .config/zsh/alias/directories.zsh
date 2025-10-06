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
    case "$#" in
    0 ) cd ;;
    1 )
        while ! [ -d "$1" ] ; do
            [ -e "$1" ] || break
            echo "# gd: argument exists but not a directory" >&2
            return 1
        done
        mkdir -p "$1" || return $?
        cd "$1"
    ;;
    * )
        echo "# gd: takes no more than one argument, seen instead: $#" >&2
    ;;
    esac
}
