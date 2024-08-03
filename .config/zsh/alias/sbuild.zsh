#!/bin/zsh

krd-debsrc() {
    (( $+commands[deb-src-export] )) || return 127

    [ -n "${1:?}" ]

    local dstdir
    case "$1" in
    */* ) dstdir="$1/src" ;;
    * )   dstdir="/tmp/$1/src" ;;
    esac
    rm -rf "${dstdir}"
    deb-src-export "${dstdir}"
}

krd-sbuild() {
    (( $+commands[sbuild] )) || return 127
    (( $+commands[xz] ))     || return 127

    [ -n "${1:?}" ]
    [ -n "${2:?}" ]

    local topdir
    case "$1" in
    */* ) topdir="$1" ;;
    * )   topdir="/tmp/$1" ;;
    esac
    [ -d "${topdir}" ] || return 1

    local srcdir="${topdir}/src"
    [ -d "${srcdir}" ] || return 2

    arch="$2"

    ## done with args
    shift 2

    local -a sbuild_env sbuild_args
    local i
    for i ; do
        ## naive splitting args and env
        case "$i" in
        -*)   sbuild_args+=( $i ) ;;
        *=* ) sbuild_env+=( $i ) ;;
        *)    sbuild_args+=( $i ) ;;
        esac
    done

    (
        for i ( ${sbuild_env} ) ; do
            export "$i"
        done

        z-set-tmpdir /tmp

        builddir="${topdir}/${arch}"
        mkdir -p "${topdir}/all" "${builddir}" "${builddir}-debug"

        cd "${builddir}"
        for i ( "${srcdir}"/*.dsc(N.r) ) ; do
            idle sbuild --arch-all --arch-any --arch=${arch} ${sbuild_args[@]} "$i"
            find -name '*.build' -type l -exec rm -f {} +
            find -name '*.build' -type f -exec xz -9vv {} +
        done

        find -name '*dbgsym*.deb' -type f -exec mv -nvt "../${arch}-debug" {} +
        find -name '*_all.deb' -type f -exec mv -nvt '../all' {} +
    )
}
