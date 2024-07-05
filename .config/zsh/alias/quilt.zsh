#!/bin/zsh

z-quilt() { command quilt "$@" ; }

quilt-series-strip-comments() {
    sed -E '/^[[:space:]]*(#|$)/d' "$@"
}

quilt-series-auto() {
    [ -n "${1:?}" ]
    [ -d "$1" ] || return 1

    find "$1/" -follow -type f -printf '%P\0' \
    | sed -zEn '/\.(diff|patch)$/p' \
    | sort -zuV \
    | xargs -0r printf '%s\n'
}

krd-quilt() {
    (( $+commands[quilt] )) || return 127

    [ $# -gt 0 ] || return 1

    local i
    local -i n_opt=0
    local -i o_continue=0
    for i ; do
        case "${i:?}" in
        -c | --continue )
            o_continue=1
        ;;
        -* )
            env printf 'unrecognized option: %q\n' "$1"
            return 1
        ;;
        * ) break ;;
        esac
        n_opt=$[n_opt+1]
    done

    [ ${n_opt} -eq 0 ] || shift ${n_opt}
    [ $# -gt 0 ] || return 1
    [ -n "${1:?}" ]

    local patchdir series tmp_series

    if [ -d "$1" ] ; then
        patchdir="$1/debian/patches"
        if [ -d "${patchdir}" ] ; then
            [ -f "${patchdir}/series" ] || return 1
        else
            patchdir="$1"
        fi

        series="${patchdir}/series"
        if ! [ -f "${series}" ] ; then
            mkdir -p "$1/.pc" || return 1
            series="$1/.pc/krd-quilt-series"
            touch "${series}" || return 1
            quilt-series-auto "${patchdir}" > "${series}"
        fi
    elif [ -f "$1" ] ; then
        [ -s "$1" ] || return 1

        series="$1"
        patchdir=${series:h}
    else
        return 1
    fi

    local r
    (
        z-quilt-default-env
        set -a
        QUILT_SERIES="${series}"
        QUILT_PATCHES="${patchdir}"
        set +a

        if [ ${o_continue} -eq 0 ] ; then
            z-quilt pop -a
            echo
        fi

        r=0
        while read -rs i ; do
            [ -n "$i" ] || continue

            k="${patchdir}/$i"
            z-quilt --fuzz=0 push "$k"
            r=$? ; [ $r -eq 0 ] || exit $r
            z-quilt refresh "$k"
            r=$? ; [ $r -eq 0 ] || exit $r

            sed -E -i \
              -e 's#^(-{3} )[^/][^/]*/(.*)$#\1a/\2#;' \
              -e 's#^(\+{3} )[^/][^/]*/(.*)$#\1b/\2#' \
            "$k"

            rm -f "$k"'~'
        done <<< $(
            if [ ${o_continue} -eq 1 ] ; then
                z-quilt unapplied
            else
                quilt-series-strip-comments "${series}"
            fi
        )
        exit $r
    )
    r=$?

    return $r
}
