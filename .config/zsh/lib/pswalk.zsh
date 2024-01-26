#!/bin/zsh

typeset -Uga ZSHU_PARENTS_PID
typeset -ga ZSHU_PARENTS_NAME

function {
    local i c

    i=$$ ; while : ; do
        i=$(ps -o ppid= -p $i 2>/dev/null) || :
        i=${i//[^0-9]}
        [[ "$i" =~ '^[1-9][0-9]*$' ]] || break
        ## don't deal with PID1
        [ "$i" = 1 ] && continue
        ZSHU_PARENTS_PID+=( $i )
    done

    for i ( ${ZSHU_PARENTS_PID} ) ; do
        c=$(ps -o comm= -p $i 2>/dev/null) || :
        [ -n "$c" ] || continue
        ZSHU_PARENTS_NAME+=( "${c:t}" )
    done

    typeset -r ZSHU_PARENTS_PID
    typeset -r ZSHU_PARENTS_NAME
}

typeset -gA ZSHU_RUN

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

z-run-test gui       konsole xterm x-terminal-emulator
z-run-test nested    screen tmux mc
z-run-test nested1L  mc
z-run-test elevated  sudo su
