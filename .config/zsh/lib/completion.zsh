#!/bin/zsh

ZSHU[f_compdump]="${ZSHU[d_cache]}/compdump"
ZSHU[d_compcache]="${ZSHU[d_cache]}/compcache"
[ -d "${ZSHU[d_compcache]}" ] || mkdir -p "${ZSHU[d_compcache]}"

fpath=( "${ZSHU[d_cache]}/completion" $fpath )

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
    local f

    (( ${+commands[$1]} )) || return 1
    (( ${+_comps[$1]} ))   && return 2

    f="${ZSHU[d_cache]}/completion/_$1"
    if ! [ -s "$f" ] ; then
        "$2" > "$f" || return 3
    fi
    autoload -Uz "_$1"

    return 0
}

__z_comp_system() {
    local d

    (( ${+commands[$1]} )) || return 1
    (( ${+_comps[$1]} ))   && return 2

    for d ( $fpath ) ; do
        [ -s "$d/_$1" ] || continue
        autoload -Uz "_$1"
        return 0
    done

    return 3
}

## reload or new session are required to regenerate compcache
z-comp-invalidate() {
    local f

    [ -n "$1" ] || return 1

    f="${ZSHU[d_cache]}/completion/_$1"
    [ -f "$f" ] || return 2
    rm -f "$f" || return 3
}
