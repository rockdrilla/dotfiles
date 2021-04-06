#!/bin/zsh

bud() { command buildah bud --isolation chroot --network host --format docker -f "$@" ; }
