#!/bin/zsh

__z_comp_kubectl() { command kubectl completion zsh ; }
__z_comp_external kubectl __z_comp_kubectl
unset -f __z_comp_kubectl
