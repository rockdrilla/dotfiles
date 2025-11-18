#!/bin/zsh

alias gar='git-archive-ref '
alias gbr='git-br '
alias gds='git diff -p --stat=200 '
alias gdu='git-dir-usage '
alias ggc='git-gc '
alias ggcf='git-gc-force '
alias gst='git status -s '

git-gc() {
    local gitdir ; local -a shallows
    git-dir-usage || return $?
    echo

    gitdir=$(ro-git rev-parse --git-dir)
    # preserve shallow references: "git gc" MAY override them silently
    if [ -s "${gitdir}/shallow" ] ; then
        shallows=(${(@f)mapfile[${gitdir}/shallow]})
    fi

    echo "# git gc $*" >&2
    z-time idle git gc "$@"
    echo

    # restore shallow references (if any)
    if [ ${#shallows} -gt 0 ] ; then
        for i (${shallows}) ; do
            printf '%s\n' "$i"
        done > "${gitdir}/shallow"
    fi

    git-dir-usage
}

git-gc-force() {
    local gitdir ; local -a shallows
    git-dir-usage || return $?
    echo

    gitdir=$(ro-git rev-parse --git-dir)
    # preserve shallow references: "git gc" MAY override them silently
    if [ -s "${gitdir}/shallow" ] ; then
        shallows=(${(@f)mapfile[${gitdir}/shallow]})
    fi

    echo "# git gc --aggressive --force $*" >&2
    z-time idle git gc --aggressive --force "$@"
    echo

    # restore shallow references (if any)
    if [ ${#shallows} -gt 0 ] ; then
        for i (${shallows}) ; do
            printf '%s\n' "$i"
        done > "${gitdir}/shallow"
    fi

    echo "# git repack -Ad" >&2
    z-time idle git repack -Ad
    echo
    git-dir-usage
}

git-br() {
    git -c core.pager='cat' branch --no-abbrev "$@"
}

git-rebase-log() {
    ro-git log --format='pick %h # %s' --reverse "$@"
}
