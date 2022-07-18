#!/bin/zsh

for i ( buildah ) ; do
    __z_comp_bash $i
done ; unset i
