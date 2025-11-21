#!/bin/zsh

alias gar='git-archive-ref '
alias gbr='git -c core.pager=cat branch --no-abbrev '
alias gds='git diff -p --stat=200 '
alias gdu='git-dir-usage '
alias ggc='git-gc '
alias ggcf='git-gc-full '
alias gst='git status -s '

git-gc() {
    z-git-gc "$@"
}

git-gc-full() {
    z-git-gc --aggressive "$@"
}

git-rebase-log() {
    ro-git log --format='pick %h # %s' --reverse "$@"
}
