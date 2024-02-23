#!/bin/zsh

typeset -gA ZSHU_COMP_FORCE

ZSHU[f_compdump]="${ZSHU[d_cache]}/compdump"
ZSHU[d_completion]="${ZSHU[d_cache]}/completion"
ZSHU[d_compzwc]="${ZSHU[d_cache]}/compzwc"
ZSHU[d_compcache]="${ZSHU[d_cache]}/compcache"

typeset -a ZSHU_SYS_FPATH=( ${fpath} )
fpath=( "${ZSHU[d_compzwc]}" "${ZSHU[d_completion]}" ${fpath} )

__z_compdump_print() { printf '#zshu %s %s\n' "$1" "${(P)1}" ; }

__z_compdump_invalidate() {
    rm -f "${ZSHU[f_compdump]}"
    find "${ZSHU[d_compcache]}/" -xdev -type f '!' -name '.keep' -delete
    ZSHU[compdump_refresh]=1
}

__z_compdump_verify() {
    local i s

    unset 'ZSHU[compdump_refresh]'
    ZSHU[compdump_meta]='ZSH_VERSION ZSH_PATCHLEVEL FPATH PATH'
    for i ( ${(s: :)ZSHU[compdump_meta]} ) ; do
        s=$(__z_compdump_print "$i")
        command grep -Fx -e "$s" "${ZSHU[f_compdump]}" &>/dev/null && continue
        __z_compdump_invalidate
        break
    done
}

__z_compdump_finalize() {
    local i

    if (( ${+ZSHU[compdump_refresh]} )) ; then
        {
            echo
            for i ( ${(s: :)ZSHU[compdump_meta]} ) ; do
                __z_compdump_print "$i"
            done
        } | tee -a "${ZSHU[f_compdump]}" &>/dev/null
        unset 'ZSHU[compdump_refresh]'
    fi
    unset 'ZSHU[compdump_meta]'
}

## TODO: refactor (e.g. buildah completion is a "bit" broken)
__z_comp_bash() {
    local f p x

    (( ${+commands[$1]} )) || return 1
    (( ${+_comps[$1]} )) && return 2
    (( ${+ZSHU[compdump_bash]} )) || return 3
    (( ${+2} )) && return 0

    f=0
    for p ( /usr/share/bash-completion/completions ) ; do
        x="_$1" ; [ -s "$p/$x" ] && f=1 && break
        x="$1"  ; [ -s "$p/$x" ] && f=1 && break
    done
    [ "$f" = 0 ] && return 4
    complete -C "$x" "$1"

    return 0
}

__z_comp_external() {
    local c f
    c="$1" ; shift

    [ $# -gt 0 ] || return 1

    (( ${+commands[$c]} )) || return 2

    if ! (( ${+ZSHU_COMP_FORCE[$c]} )) ; then
        (( ${+_comps[$c]} )) && return 0
    fi

    f="${ZSHU[d_completion]}/_$c"
    if ! [ -s "$f" ] ; then
        if ! "$@" > "$f" ; then
            rm -f "$f"
            return 3
        fi
    fi
    # zcompile -zR "$f"
    # mv -f "$f.zwc" "${ZSHU[d_compzwc]}/$c.zwc"
    # emulate zsh -c "autoload -Uz _$c"
    autoload -Uz "_$c"

    return 0
}

__z_comp_system() {
    local d

    (( ${+commands[$1]} )) || return 1
    (( ${+_comps[$1]} ))   && return 2

    (( ${+ZSHU_COMP_FORCE[$c]} )) && return 0

    local -a _fpath
    _fpath=( ${fpath} )
    fpath=( ${ZSHU_SYS_FPATH} )

    for d ( ${fpath} ) ; do
        [ -s "$d/_$1" ] || continue
        # emulate zsh -c "autoload -Uz _$1"
        autoload -Uz "_$1"
        fpath=( ${_fpath} )
        return 0
    done
    fpath=( ${_fpath} )
    return 3
}

## reload or new session are required to regenerate compcache
z-comp-invalidate() {
    [ -n "$1" ] || return 1

    # rm -f "${ZSHU[d_completion]}/_$1" "${ZSHU[d_compzwc]}/_$1.zwc" "${ZSHU[d_compzwc]}/$1.zwc"
    rm -f "${ZSHU[d_completion]}/_$1"
}

## reload or new session are required to regenerate completions
z-comp-flush() {
    find "${ZSHU[d_completion]}/" "${ZSHU[d_compzwc]}/" -xdev -type f '!' -name '.keep' -delete
}

z-comp-auto() {
    local c f

    for c ( ${(k)ZSHU_COMP_EXTERNAL} ) ; do
        __z_comp_external "$c" "${(@s: :)ZSHU_COMP_EXTERNAL[$c]}" && unset "ZSHU_COMP_EXTERNAL[$c]"
    done

    for f ( ${functions[(I)__z_comp_ext__*]} ) ; do
        c=${f#__z_comp_ext__}
        __z_comp_external $c $f && unset -f "$f"
    done
}