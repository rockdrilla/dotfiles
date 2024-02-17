#!/bin/zsh

typeset -A ZSHU_COMP_EXTERNAL

for i ( kubectl podman skopeo docker ) ; do
    ZSHU_COMP_EXTERNAL[$i]="command $i completion zsh"
done ; unset i
# ZSHU_COMP_EXTERNAL[yq]='command yq shell-completion zsh'
## example of "automatic" shell completion generation
__z_comp_ext__yq() { command yq shell-completion zsh ; }

## example of more complex shell completion generation
# __z_comp__shifty_nifty() { command shifty-nifty completion zsh | sed -E 's/shifty_nifty/shifty-nifty/g' ; }
# ZSHU_COMP_EXTERNAL[shifty-nifty]='__z_comp__shifty_nifty'

z-comp-auto() {
    local c f

    for c ( ${(k)ZSHU_COMP_EXTERNAL} ) ; do
        __z_comp_external "$c" "${(@s: :)ZSHU_COMP_EXTERNAL[$c]}" && unset "ZSHU_COMP_EXTERNAL[$c]"
    done

    for f ( ${functions[(I)__z_comp_ext__*]} ) ; do
        c=${f#__z_comp_ext__}
        __z_comp_external $c $f && unset -f "$f"
    done
}
z-comp-auto
