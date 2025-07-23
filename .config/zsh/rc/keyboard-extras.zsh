#!/bin/zsh

## TODO: more fzf locations
for i ( /usr/share/doc/fzf/examples/key-bindings.zsh ) ; do
    [ -s "$i" ] || continue
    source $i
done ; unset i
