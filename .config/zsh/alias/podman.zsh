#!/bin/zsh

run() { command podman run --network host --rm -it "$@" ; }
