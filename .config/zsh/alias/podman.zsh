#!/bin/zsh

run() { command podman run ${TERM:+-e "TERM=$TERM"} --network host --rm -it "$@" ; }
run-sh() { run --entrypoint='["/bin/sh"]' --user=0:0 "$@" ; }
