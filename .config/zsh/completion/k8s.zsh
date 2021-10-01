#!/bin/zsh

__z_comp_kubectl() {
    command kubectl completion zsh
#   complete -F __start_kubectl k
}
__z_comp_external kubectl __z_comp_kubectl
unset -f __z_comp_kubectl
