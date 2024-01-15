#!/bin/zsh

## fancy and manageable PS1 for git
typeset -gA ZSHU_GIT ZSHU_PM ZSHU_PS
ZSHU_PS[git]=0
ZSHU_PM[git_branch]='🞷'
ZSHU_PM[git_detach]='☈'
ZSHU_PM[git_tag]='🗹'
ZSHU_PM[git_commit]='⌽'

__z_git_avail() { (( $+commands[git] )) ; }

__z_git() { GIT_OPTIONAL_LOCKS=0 command git "$@"; }

__z_git_is_repo() { __z_git rev-parse --git-dir &>/dev/null ; }

__z_git_desc_tag() { __z_git describe --tags "$@" ; }

z-git-test() {
    [ "${ZSHU_PS[git]}" = '1' ] || return 1

    __z_git_avail || return 2

    __z_git_is_repo || return 3

    return 0
}

__z_git_pwd() {
    local x

    unset 'ZSHU_PS[git_ref]' 'ZSHU_PS[git_tag]'
    unset 'ZSHU_GIT[path_root]' 'ZSHU_GIT[path_mid]' 'ZSHU_GIT[path_last]'
    unset 'ZSHU_GIT[commit]' 'ZSHU_GIT[detached]' 'ZSHU_GIT[ref]' 'ZSHU_GIT[tag]'

    z-git-test || return

    x=$(__z_git rev-parse --short HEAD 2>/dev/null)
    [ -n "$x" ] || return
    ZSHU_GIT[commit]=$x

    ## git ref
    while : ; do
        ZSHU_GIT[detached]=1
        x=$(__z_git symbolic-ref --short HEAD 2>/dev/null)
        if [ -n "$x" ] ; then
            ZSHU_GIT[detached]=0
            ZSHU_GIT[ref]=$x
            ZSHU_PS[git_ref]="%F{green}%B${ZSHU_PM[git_branch]}%b ${ZSHU_GIT[ref]}%f"
            break
        fi

        x=$(__z_git for-each-ref --format='%(refname)' --count=1 --points-at=${ZSHU_GIT[commit]} refs/heads/ refs/remotes/)
        if [ -n "$x" ] ; then
            ZSHU_GIT[detached]=0
            ZSHU_GIT[ref]=${x#refs/*/}
            ZSHU_PS[git_ref]="%F{yellow}%B${ZSHU_PM[git_branch]}%b ${ZSHU_GIT[ref]}%f"
            break
        fi

        ZSHU_GIT[ref]=${ZSHU_GIT[commit]}
        ZSHU_PS[git_ref]="%F{red}%B${ZSHU_PM[git_detach]}%b ${ZSHU_GIT[ref]}%f"

        break
    done

    ## git tag
    while [ ${ZSHU_GIT[detached]} = 1 ] ; do
        x=$(__z_git_desc_tag --exact-match HEAD 2>/dev/null)
        if [ -n "$x" ] ; then
            ZSHU_GIT[tag]=$x
            ZSHU_PS[git_tag]="%F{green}%B${ZSHU_PM[git_tag]}%b ${ZSHU_GIT[tag]}%f"
            break
        fi

        x=$(__z_git_desc_tag HEAD 2>/dev/null)
        if [ -n "$x" ] ; then
            ZSHU_GIT[tag]=${x%-*}
            ZSHU_PS[git_tag]="%F{yellow}%B${ZSHU_PM[git_commit]}%b ${ZSHU_GIT[tag]}%f"
            break
        fi

        break
    done

    ## try to fancy split current path
    while : ; do
        x=${(%):-%~}
        [[ "$x" =~ '/.+' ]] || break

        local pfx last mid
        pfx=$(__z_git rev-parse --show-prefix)
        pfx="${pfx%/}"
        if [ -n "${pfx}" ] ; then
            x=${x%/${pfx}}
            last="${pfx:t}"
            mid="${pfx%${last}}"
            mid="${mid%/}"
            mid="/${mid}${mid:+/}"

            ZSHU_GIT[path_mid]=${mid}
            ZSHU_GIT[path_last]=${last}
        else
            ZSHU_GIT[path_last]='/'
        fi
        break
    done
    ZSHU_GIT[path_root]=$x

    x="%F{magenta}${ZSHU_GIT[path_root]:gs/%/%%}"
    x="$x%F{cyan}${ZSHU_GIT[path_mid]:gs/%/%%}"
    x="$x%B${ZSHU_GIT[path_last]:gs/%/%%}%f%b"
    ZSHU_PS[pwd]=$x

    x="${ZSHU_PS[git_tag]}"
    ZSHU_PS[pwd_extra]=" ${ZSHU_PS[git_ref]}${x:+ }$x"
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
