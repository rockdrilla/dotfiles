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

        r=0
        while read -rs i ; do
            [ -n "$i" ] || continue

            z-quilt --fuzz=0 push "$i"
            r=$? ; [ $r -eq 0 ] || exit $r
            z-quilt refresh "$i"
            r=$? ; [ $r -eq 0 ] || exit $r

            sed -E -i \
              -e 's#^(-{3} )[^/][^/]*/(.*)$#\1a/\2#;' \
              -e 's#^(\+{3} )[^/][^/]*/(.*)$#\1b/\2#' \
            "$i"

            rm -f "$i"'~'
        done <<< $(
            if ! z-quilt unapplied ; then
                quilt-series-strip-comments "${series}" \
                | sed -E "s${ZSHU_XSED}^${ZSHU_XSED}${patchdir}/${ZSHU_XSED}"
            fi
        )
        exit $r
    )
    r=$?

    return $r
}
