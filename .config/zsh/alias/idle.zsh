#!/bin/zsh

function {
    local -a s
    s+=( $(z-alt-find 'nice -n +40') )
    s+=( $(z-alt-find 'chrt -i 0'  ) )
    s+=( $(z-alt-find 'ionice -c 3') )
    z-alt-set-static idle "$s|env"
}
