#!/bin/zsh

typeset -g -A ZSHU_COMP_EXTERNAL

for i ( kubectl podman skopeo docker ) ; do
    ZSHU_COMP_EXTERNAL[$i]="command $i completion zsh"
done ; unset i

## example of "automatic" shell completion generation
# ZSHU_COMP_EXTERNAL[yq]='command yq shell-completion zsh'
__z_comp_ext__yq() { command yq shell-completion zsh ; }

## example of more complex shell completion generation
# __z_comp__shifty_nifty() { command shifty-nifty completion zsh | sed -E 's/shifty_nifty/shifty-nifty/g' ; }
# ZSHU_COMP_EXTERNAL[shifty-nifty]='__z_comp__shifty_nifty'

z-comp-auto
