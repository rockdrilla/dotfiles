#!/bin/zsh

## fancy and manageable PS1 for git
typeset -gA ZSHU_PS
ZSHU_PS[git]=0

_zshu_git_avail() { (( $+commands[git] )) ; }

_zshu_git() { GIT_OPTIONAL_LOCKS=0 command git "$@"; }

_zshu_git_is_repo() { _zshu_git rev-parse --git-dir &>/dev/null ; }

zshu-git-test() {
    [ "${ZSHU_PS[git]}" = '1' ] || return 1

    _zshu_git_avail || return 2

    _zshu_git_is_repo || return 3

    return 0
}

_zshu_git_pwd() {
    zshu-git-test || return
    local p=${(%):-%~}
    [[ "$p" =~ '/.+' ]] || return
    local s pfx last
    s=$(_zshu_git rev-parse --show-prefix)
    s="${s%%/}"
    if [ -n "$s" ] ; then
        p=${p%%/$s}
        last="${s:t}"
        pfx="${s%${last}}"
        pfx="${pfx%/}"
        pfx="/${pfx}${pfx:+/}"
    else
        last="/"
    fi
    ZSHU_PS[pwd]="%F{magenta}$p%F{cyan}${pfx}%B${last}%f%b"
}

zshu-git-enable()  { ZSHU_PS[git]=1 ; }
zshu-git-disable() { ZSHU_PS[git]=0 ; }

zshu-git-status() {
    _zshu_git_avail
    echo "Git binary: "${(%):-%(?..NOT )}"found in PATH"
    [ "${ZSHU_PS[git]}" = 1 ]
    echo "Git prompt: "${(%):-%(?.enabled.disabled)}
    _zshu_git_is_repo
    echo "Git repo: "${(%):-%(?..NOT )}"present"
}

ZSHU[pwd_hook]="${ZSHU[pwd_hook]}${ZSHU[pwd_hook]:+ }_zshu_git_pwd"
