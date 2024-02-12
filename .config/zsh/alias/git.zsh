#!/bin/zsh

git-dir-usage() {
    local gitdir x topdir
    gitdir=$(__z_git rev-parse --git-dir) || return $?
    x=$(__z_git rev-parse --path-format=absolute 2>/dev/null) || return $?
    if [ -n "$x" ] ; then
        ## older git version which does not support "--path-format=absolute"
        : TODO
    else
        gitdir=$(__z_git rev-parse --path-format=absolute --git-dir) || return $?
    fi

    case "${gitdir}" in
    */* ) topdir=${gitdir:h} ; gitdir=${gitdir:t} ;;
    esac

    local -a subdirs
    subdirs+="${gitdir}/logs/refs"
    subdirs+="${gitdir}/objects/info"
    subdirs+="${gitdir}/objects/pack"

    if [ -n "${topdir}" ] ; then
        env -C "${topdir}" du -d1 "${gitdir}"
        env -C "${topdir}" du -d1 "${subdirs[@]}"
    else
        du -d1 "${gitdir}"
        du -d1 "${subdirs[@]}"
    fi | grep -Ev '^[0-9]\s' | sort -Vk2
}

git-gc() {
    git-dir-usage || return $?
    echo
    idle git gc "$@"
    echo
    git-dir-usage
}

git-gc-force() {
    git-gc --aggressive --force
}

git-archive-ref() {
    local name ver gitref topdir c_hash c_time out
    name="${1:?}" ver="${2:?}" gitref="${3:?}"
    topdir=$(__z_git rev-parse --show-toplevel) || return $?
    c_hash=$(__z_git log -n 1 --format='%h' --abbrev=8 "${gitref}") || return $?
    c_time=$(__z_git log -n 1 --format='%cd' --date='format:%Y%m%d.%H%M%S' "${gitref}") || return $?
    out="${name}_${ver}+git.${c_time}.${c_hash}.tar"
    topdir=${topdir:h}
    git archive --format=tar -o "${topdir}/${out}" --prefix="${name}-${ver}-git.${c_hash}/" "${gitref}" || return $?
    echo "archived to ${out} in ${topdir}/" >&2
}