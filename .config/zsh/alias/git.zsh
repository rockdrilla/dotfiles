#!/bin/zsh

alias gar='git-archive-ref '
alias gbr='git-br '
alias gds='git diff -p --stat=200 '
alias gdu='git-dir-usage '
alias ggc='git-gc '
alias ggcf='git-gc-force '
alias gst='git status -s '

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
    for x ( logs/refs objects/info objects/pack ) ; do
        [ -d "${gitdir}/$x" ] || continue
        subdirs+="${gitdir}/$x"
    done
    
    (
        [ -n "${topdir}" ] && cd "${topdir}/"
        if [ ${#subdirs} -gt 0 ] ; then
            du -d1 "${subdirs[@]}"
        fi
        du -d1 "${gitdir}"
    ) | grep -Ev '^[0-9]K?\s' | sort -Vk2
}

git-gc() {
    git-dir-usage || return $?
    echo
    echo "# git gc $*" >&2
    z-time idle git gc "$@"
    echo
    git-dir-usage
}

git-gc-force() {
    git-dir-usage || return $?
    echo
    echo "# git gc --aggressive --force $*" >&2
    z-time idle git gc --aggressive --force "$@"
    echo
    echo "# git repack -Ad" >&2
    z-time idle git repack -Ad
    echo
    git-dir-usage
}

git-archive-ref() {
    local name ver gitref topdir c_hash c_time out
    name="${1:?}" ver="${2:?}" gitref="${3:?}"
    topdir=$(__z_git rev-parse --show-toplevel) || return $?
    c_hash=$(__z_git log -n 1 --format='%h' --abbrev=12 "${gitref}") || return $?
    c_time=$(__z_git log -n 1 --format='%cd' --date='format:%Y%m%d.%H%M%S' "${gitref}") || return $?
    out="${name}_${ver}+git.${c_time}.${c_hash}.tar"
    topdir=${topdir:h}
    git archive --format=tar -o "${topdir}/${out}" --prefix="${name}-${ver}-git.${c_hash}/" "${gitref}" || return $?
    echo "archived to ${out} in ${topdir}/" >&2
}

git-br() {
    __z_git -c core.pager='cat' branch --no-abbrev "$@"
}

git-rebase-log() {
    git log --format='pick %h # %s' --reverse "$@"
}
