#!/bin/zsh

typeset -Uga ZSHU_PARENTS_PID
typeset -ga ZSHU_PARENTS_NAME

function {
    local i cmd

    i=$$ ; while : ; do
        i=$(ps -o ppid= -p $i 2>/dev/null || : )
        i=${i//[^0-9]}
        [[ "$i" =~ '^[1-9][0-9]*$' ]] || break
        ## don't deal with PID1
        [ "$i" = 1 ] && continue
        ZSHU_PARENTS_PID+=( $i )
    done

    for i ( ${ZSHU_PARENTS_PID} ) ; do
        cmd=$(ps -o comm= -p $i 2>/dev/null || : )
        [ -n "${cmd}" ] && ZSHU_PARENTS_NAME+=( "${cmd##*/}" )
    done

    typeset -r ZSHU_PARENTS_PID
    typeset -r ZSHU_PARENTS_NAME
}

typeset -gA ZSHU_RUN

z-run-test() {
    local key v i

    key=$1 ; shift
    v=0
    for i ( ${ZSHU_PARENTS_NAME} ) ; do
        if (( ${+argv[(r)$i]} )) ; then
            ZSHU_RUN[${key}]=1
            return
        fi
    done
    ZSHU_RUN[${key}]=0
}

z-run-test gui       konsole xterm x-terminal-emulator
z-run-test nested    screen tmux mc
z-run-test nested1   mc
z-run-test elevated  sudo su
