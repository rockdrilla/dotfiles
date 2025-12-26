#!/bin/zsh

typeset -g -aU ZSHU_PARENTS_PID
typeset -g -a ZSHU_PARENTS_NAME

function {
    local i c x _unused

    i=${PPID}
    while : ; do
        [ -n "$i" ] || break
        ## don't deal with PID1
        [ "$i" = 1 ] && break

        ZSHU_PARENTS_PID+=( $i )

        c=
        while [ -n "${ZSHU[procfs]}" ] ; do
            [ -f "${ZSHU[procfs]}/$i/cmdline" ] || break
            read -d $'\0' -rs c <<< $(cat "${ZSHU[procfs]}/$i/cmdline")
        break;done
        if [ -z "$c" ] ; then
            read -rs c _unused <<< "$(ps -o 'comm=' -p "$i" 2>/dev/null)"
        fi
        [ -n "$c" ] && ZSHU_PARENTS_NAME+=( "${c:t}" )

        x=
        while [ -n "${ZSHU[procfs]}" ] ; do
            [ -f "${ZSHU[procfs]}/$i/status" ] || break
            # read -rs _unused x <<< "$(cat "${ZSHU[procfs]}/$i/status" | grep -F 'PPid:')"
            while read -rs _unused c ; do
                [ "${_unused}" = 'PPid:' ] || continue
                x=$c
            break;done < "${ZSHU[procfs]}/$i/status"
        break;done
        if [ -z "$x" ] ; then
            read -rs x _unused <<< "$(ps -o 'ppid=' -p "$i" 2>/dev/null)"
        fi
        i=$x
    done
}

typeset -r ZSHU_PARENTS_PID ZSHU_PARENTS_NAME
