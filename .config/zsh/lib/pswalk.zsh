#!/bin/zsh

z-proc-exists() {
    [ -n "${1:?}" ]

    while [ -n "${ZSHU[procfs]}" ] ; do
        [ -d "${ZSHU[procfs]}" ] || return 1
        [ -f "${ZSHU[procfs]}/$1/status" ]
        return $?
    done

    ps -o 'pid=' -p "$1" >/dev/null 2>&1
}

typeset -g -aU ZSHU_PARENTS_PID
typeset -g -a ZSHU_PARENTS_NAME

function {
    local procfs
    while [ -n "${ZSHU[procfs]}" ] ; do
        [ -d "${ZSHU[procfs]}" ] || break
        procfs=1 ; break
    done

    local i c x _unused

    i=${PPID}
    while : ; do
        [ -n "$i" ] || break
        ## don't deal with PID1
        [ "$i" = 1 ] && break

        ZSHU_PARENTS_PID+=( $i )

        c=
        while [ "${procfs}" = 1 ] ; do
            [ -f "${ZSHU[procfs]}/$i/cmdline" ] || break
            read -d $'\0' -rs c <<< $(cat "${ZSHU[procfs]}/$i/cmdline")
            break
        done
        if [ -z "$c" ] ; then
            read -rs c _unused <<< "$(ps -o 'comm=' -p "$i" 2>/dev/null)"
        fi
        [ -n "$c" ] && ZSHU_PARENTS_NAME+=( "${c:t}" )

        x=
        while [ "${procfs}" = 1 ] ; do
            [ -f "${ZSHU[procfs]}/$i/status" ] || break
            # read -rs _unused x <<< "$(cat "${ZSHU[procfs]}/$i/status" | grep -F 'PPid:')"
            while read -rs _unused c ; do
                [ "${_unused}" = 'PPid:' ] || continue
                x=$c ; break
            done < "${ZSHU[procfs]}/$i/status"
            break
        done
        if [ -z "$x" ] ; then
            read -rs x _unused <<< "$(ps -o 'ppid=' -p "$i" 2>/dev/null)"
        fi
        i=$x
    done

    typeset -r ZSHU_PARENTS_PID ZSHU_PARENTS_NAME
}

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

z-run-test gui       konsole xterm x-terminal-emulator
z-run-test nested    SCREEN screen tmux mc
z-run-test nested1L  mc
z-run-test elevated  sudo su
