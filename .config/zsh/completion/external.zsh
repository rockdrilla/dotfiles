#!/bin/zsh

__z_comp__kubectl() { command kubectl completion zsh ; }
__z_comp__podman() { command podman completion zsh ; }

for i ( kubectl podman ) ; do
    __z_comp_external $i "__z_comp__$i"
done ; unset i
unset -fm '__z_comp__*'
