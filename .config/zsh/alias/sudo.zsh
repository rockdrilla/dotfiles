#!/bin/zsh

function {
    local c
    if [ ${UID} -ne 0 ] ; then
        c='sudo -i '
    fi
    alias sudo-i="$c"
    alias sudoi="$c"
}
