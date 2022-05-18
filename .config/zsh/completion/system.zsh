#!/bin/zsh

for i ( fd fdfind hyperfine ) ; do
    __z_comp_system $i
done
