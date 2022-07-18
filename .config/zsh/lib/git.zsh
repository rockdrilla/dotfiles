#!/bin/zsh

## fancy and manageable PS1 for git
typeset -gA ZSHU_PS
ZSHU_PS[git]=0

__z_git_avail() { (( $+commands[git] )) ; }

__z_git() { GIT_OPTIONAL_LOCKS=0 command git "$@"; }

__z_git_is_repo() { __z_git rev-parse --git-dir &>/dev/null ; }

z-git-test() {
    [ "${ZSHU_PS[git]}" = '1' ] || return 1

    __z_git_avail || return 2

    __z_git_is_repo || return 3

    return 0
}

__z_git_pwd() {
    local p s last pfx

    z-git-test || return

    p=${(%):-%~}
    [[ "$p" =~ '/.+' ]] || return
    s=$(__z_git rev-parse --show-prefix)
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

z-git-enable()  { ZSHU_PS[git]=1 ; }
z-git-disable() { ZSHU_PS[git]=0 ; }

z-git-status() {
    __z_git_avail
    echo "Git binary: "${(%):-%(?..NOT )}"found in PATH"
    [ "${ZSHU_PS[git]}" = 1 ]
    echo "Git prompt: "${(%):-%(?.enabled.disabled)}
    __z_git_is_repo
    echo "Git repo: "${(%):-%(?..NOT )}"present"
}

ZSHU[pwd_hook]="${ZSHU[pwd_hook]}${ZSHU[pwd_hook]:+ }__z_git_pwd"
