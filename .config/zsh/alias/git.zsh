#!/bin/zsh

alias gar='git-archive-ref '
alias gbr='git-br '
alias gds='git diff -p --stat=200 '
alias gdu='git-dir-usage '
alias ggc='git-gc '
alias ggcf='git-gc-force '
alias gst='git status -s '

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

git-br() {
    git -c core.pager='cat' branch --no-abbrev "$@"
}

git-rebase-log() {
    ro-git log --format='pick %h # %s' --reverse "$@"
}
