#!/bin/zsh

alias run='podman run -e "TERM=$TERM" --network host --rm -it '
alias run-sh="run --entrypoint='[\"/bin/sh\"]' --user=0:0 "
