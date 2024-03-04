#!/bin/zsh

quilt-series-strip-comments() {
    sed -E '/^[[:space:]]*(#|$)/d' "$@"
}

quilt-series-auto() {
    [ -n "${1:?}" ]

    find "$1/" -follow -type f -printf '%P\0' \
    | sed -zEn '/\.(diff|patch)$/p' \
    | sort -zuV | xargs -0r -n1
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
            tmp_series=1
            series=$(mktemp)
            quilt-series-auto "${patchdir}" > "${series}"
        fi
    elif [ -f "$1" ] ; then
        [ -s "$1" ] || return 2

        series="$1"
        patchdir=${series:h}
    else
        return 3
    fi

    local r
    (
        z-quilt-default-env
        set -a
        QUILT_SERIES="${series}"
        QUILT_PATCHES="${patchdir}"
        set +a

        command quilt pop -a ; echo

        r=0
        while read -rs i ; do
            [ -n "$i" ] || continue

            k="${patchdir}/$i"
            command quilt --fuzz=0 push "$k"
            r=$? ; [ $r -eq 0 ] || exit $r
            command quilt refresh "$k"
            r=$? ; [ $r -eq 0 ] || exit $r

            sed -E -i \
              -e 's#^(-{3} )[^/][^/]*/(.*)$#\1a/\2#;' \
              -e 's#^(\+{3} )[^/][^/]*/(.*)$#\1b/\2#' \
            "$k"

            rm -f "$k"'~'
        done <<< $(quilt-series-strip-comments "${series}")
        exit $r
    )
    r=$?

    [ -z "${tmp_series}" ] || rm -f "${series}"

    return $r
}
