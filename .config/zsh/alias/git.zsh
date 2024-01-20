#!/bin/zsh

git-dir-usage() {
    local d x p
    d=$(__z_git rev-parse --git-dir) || return $?
    x=$(__z_git rev-parse --path-format=absolute 2>/dev/null)
    if [ -n "$x" ] ; then
        ## older git version which does not support "--path-format=absolute"
        :
    else
        d=$(__z_git rev-parse --path-format=absolute --git-dir)
    fi
    case "$d" in
    */* ) p=${d%/*} ; d=${d##*/} ;;
    esac
    ## ${p:+ env -C "$p" } du -cd2 "$d"
    if [ -n "$p" ] ; then
        env -C "$p" du -cd2 "$d"
    else
        du -cd2 "$d"
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