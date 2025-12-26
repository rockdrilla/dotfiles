#!/bin/zsh

typeset -g -A ZSHU_RUN

z-run-test() {
    local k i

    k=$1 ; shift
    for i ( ${ZSHU_PARENTS_NAME} ) ; do
        (( ${+argv[(r)$i]} )) || continue

        ZSHU_RUN[$k]=1
        return
    done
    ZSHU_RUN[$k]=0
}

z-run-test  gui       konsole xterm x-terminal-emulator
z-run-test  nested    SCREEN screen tmux mc
z-run-test  nested1L  mc
z-run-test  elevated  sudo su
