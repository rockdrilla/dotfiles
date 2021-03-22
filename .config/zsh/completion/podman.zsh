#!/bin/zsh

__z_comp_podman() { command podman completion zsh ; }
__z_comp_external podman __z_comp_podman
unset -f __z_comp_podman
