#!/bin/zsh

## fancy and manageable PS1 for git
typeset -g -A ZSHU_GIT ZSHU_PM ZSHU_PS
ZSHU_PS[git]=0
ZSHU_PM[git_branch]='🞷'
ZSHU_PM[git_ahead]='↱'
ZSHU_PM[git_behind]='↴'
ZSHU_PM[git_detach]='☈'
ZSHU_PM[git_tag]='🗹'
ZSHU_PM[git_commit]='⌽'

__z_git_avail() { (( $+commands[git] )) ; }

## sync with /.config/dotfiles/scripts/ro-git
__z_git() { GIT_OPTIONAL_LOCKS=0 command git "$@"; }

__z_git_is_repo() { __z_git rev-parse --git-dir &>/dev/null ; }

__z_git_desc_tag() { __z_git describe --tags "$@" ; }

z-git-test() {
    [ "${ZSHU_PS[git]}" = '1' ] || return 1

    __z_git_avail || return $?

    __z_git_is_repo || return 3

    return 0
}

__z_git_pwd() {
    unset 'ZSHU_PS[git_ref]' 'ZSHU_PS[git_changes]' 'ZSHU_PS[git_tag]'
    ZSHU_GIT=()
    z-git-test || return


    local x
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

        x=$(__z_git for-each-ref --format='%(refname:short)' --count=1 --points-at=${ZSHU_GIT[commit]} refs/heads/ refs/remotes/)
        if [ -n "$x" ] ; then
            ZSHU_GIT[detached]=0
            ZSHU_GIT[ref]=$x
            ZSHU_PS[git_ref]="%F{yellow}%B${ZSHU_PM[git_branch]}%b ${ZSHU_GIT[ref]}%f"
            break
        fi

        ZSHU_GIT[ref]=${ZSHU_GIT[commit]}
        ZSHU_PS[git_ref]="%F{red}%B${ZSHU_PM[git_detach]}%b ${ZSHU_GIT[ref]}%f"

        break
    done

    ## local<->remote changes
    while [ ${ZSHU_GIT[detached]} = 0 ] ; do
        x=$(__z_git for-each-ref --format='%(upstream:short)' --count=1 --points-at=${ZSHU_GIT[commit]} refs/heads/ refs/remotes/)
        [ -n "$x" ] || break
        ZSHU_GIT[remote]=$x

        x=$(__z_git rev-list --left-right "${ZSHU_GIT[ref]}...${ZSHU_GIT[remote]}" 2>/dev/null) || break
        ZSHU_GIT[ref_ahead]=$(echo "$x" | grep -Ec '^<')
        ZSHU_GIT[ref_behind]=$(echo "$x" | grep -Ec '^>')
        ZSHU_GIT[ref_changes]=$[ ZSHU_GIT[ref_ahead] + ZSHU_GIT[ref_behind] ]
        [ ${ZSHU_GIT[ref_changes]} -eq 0 ] && break

        x=''
        [ ${ZSHU_GIT[ref_ahead]} -eq 0 ]  || x="$x${x:+ }%B%F{green}${ZSHU_PM[git_ahead]} ${ZSHU_GIT[ref_ahead]}%b"
        [ ${ZSHU_GIT[ref_behind]} -eq 0 ] || x="$x${x:+ }%B%F{red}${ZSHU_PM[git_behind]} ${ZSHU_GIT[ref_behind]}%b"
        ZSHU_PS[git_changes]=$x

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

    local -a ary
    ary+="${ZSHU_PS[git_ref]}"
    ary+="${ZSHU_PS[git_changes]}"
    ary+="${ZSHU_PS[git_tag]}"
    x="${(j: :)ary}"
    [ -z "$x" ] || ZSHU_PS[pwd_extra]=" $x"
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

z-git-gc() {
    local gitdir
    gitdir=$(ro-git rev-parse --git-dir) || return

    local rv
    rv=0

    # preserve shallow references: "git gc" MAY override them silently
    local -a shallows ; local shallow_before shallow_after
    z-git-gc-shallow-restore() { : ; }
    if [ -s "${gitdir}/shallow" ] ; then
        echo '# --------------------------------------'
        echo "# current /.git/shallow:"
        cat "${gitdir}/shallow"
        echo '# --------------------------------------'
        echo

        shallows=(${(@f)mapfile[${gitdir}/shallow]})
        shallow_before=$(sha256sum "${gitdir}/shallow" | awk '{print $1}')

        # restore shallow references (if any)
        z-git-gc-shallow-restore() {
            [ -n "${shallow_before}" ] || return 0

            if [ -f "${gitdir}/shallow" ] ; then
                shallow_after=$(sha256sum "${gitdir}/shallow" | awk '{print $1}')
            fi
            [ "${shallow_before}" != "${shallow_after}" ] || return 0

            if [ -s "${gitdir}/shallow" ] ; then
                echo
                echo '# --------------------------------------'
                echo "# new /.git/shallow:"
                cat "${gitdir}/shallow"
                echo '# --------------------------------------'
            fi
            echo "# restoring /.git/shallow to previous state"

            for i (${shallows}) ; do
                printf '%s\n' "$i"
            done > "${gitdir}/shallow"
        }
    fi

    local i _full
    for i ; do
        case "$i" in
        --aggressive )
            _full=1
        ;;
        esac
    done

    while : ; do
        git-dir-usage ; rv=$?
        [ ${rv} -eq 0 ] || break

        echo
        echo "# git gc $*"
        z-time idle git gc "$@" ; rv=$?
        [ ${rv} -eq 0 ] || break

        [ -n "${_full}" ] || break

        ## "git repack" wants sane /.git/shallow
        z-git-gc-shallow-restore

        echo
        echo "# git repack -Ad"
        z-time idle git repack -Ad ; rv=$?
        [ ${rv} -eq 0 ] || break

        echo
        echo "# git prune -v"
        z-time idle git prune -v ; rv=$?
        # [ ${rv} -eq 0 ] || break
    break ; done

    echo
    git-dir-usage ; rv=$?

    z-git-gc-shallow-restore
    unset -f z-git-gc-shallow-restore

    return ${rv}
}

ZSHU[pwd_hook]="${ZSHU[pwd_hook]}${ZSHU[pwd_hook]:+ }__z_git_pwd"
