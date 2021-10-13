#!/bin/zsh

run() { command podman run --network host --rm -it "$@" ; }
run-sh() { run --entrypoint='["/bin/sh"]' --user=0:0 "$@" ; }
