#!/bin/zsh

dotfiles-update() {
    "${ZSHU[d_dotfiles]}/install.sh" "$@" || return $?
}

dotfiles-git() { (
    cd "${ZSHU[d_zdot]}/"
    set -a
    GIT_DIR="${ZSHU[d_dotfiles]}/repo.git"
    GIT_WORK_TREE="${ZSHU[d_zdot]}"
    set +a
    z-reload
) }

## for use in development
dotfiles-gen-gitignore() {
    local x='.config/dotfiles/gen-gitignore.sh'
    [ -x "$x" ] || {
        echo "${x:t} is somewhere else" >&2
        return 1
    }
    if [ -d .config/dotfiles/repo.git ] ; then
        echo "NOT going to change dotfiles installation" >&2
        return 2
    fi
    "$x" "$@"
}

__z_dotfiles_dist_compare() {
    local f_src f_dst s_src s_dst

    f_src="${ZSHU[d_zdot]}/$1"
    f_dst="${ZSHU[d_zdot]}/$2"

    [ -e "${f_src}" ] || {
        echo "# source file is missing: $1" >&2
        return 0
    }
    ## skip if destination file is missing
    [ -e "${f_dst}" ] || return 0

    ## not dealing with symlinks in any way
    if [ -h "${f_src}" ] || [ -h "${f_dst}" ] ; then
        return 0
    fi

    [ -f "${f_dst}" ] || {
        echo "# destination file is not a regular file: $2" >&2
        return 0
    }

    if cmp -s "${f_src}" "${f_dst}" >/dev/null ; then
        return 0
    fi

    echo "# files differ: $1 $2" >&2
    echo "#   ${f_src}" >&2
    echo "#   ${f_dst}" >&2

    ## not dealing with "binary" files in any way
    z-is-text-file "${f_src}" || return 0
    z-is-text-file "${f_dst}" || return 0

    ## try "git diff" first
    if __z_git_avail ; then
        env -C "${ZSHU[d_zdot]}" GIT_PAGER=cat git diff "${f_src}" "${f_dst}"
        return 0
    fi

    z-diff -Naru "${f_src}" "${f_src}"
    return 0
}

__z_dotfiles_from_gitignore() {
    local f
    f="${ZSHU[d_dotfiles]}/gitignore"
    [ -s "$f" ] || return 1
    sed -En "\\${xsedx}^!/$1\$${xsedx}{$2}" < "$f"
}

dotfiles-dist-compare() {
    local tf_list f_dist

    tf_list=$(mktemp) ; : "${tf_list:?}"

    __z_dotfiles_from_gitignore '(.+\.dist)' 's//\1/;p' \
    > "${tf_list}"
    while read -r f_dist ; do
        [ -n "${f_dist}" ] || continue

        __z_dotfiles_dist_compare "${f_dist}" "${f_dist%.dist}"
    done < "${tf_list}"

    __z_dotfiles_from_gitignore '(\.config/dotfiles/dist/.+)' 's//\1/;p' \
    > "${tf_list}"
    while read -r f_dist ; do
        [ -n "${f_dist}" ] || continue

        __z_dotfiles_dist_compare "${f_dist}" "${f_dist#.config/dotfiles/dist/}"
    done < "${tf_list}"

    rm -f "${tf_list}"
}

z-zwc-gen() {
    local i
    for i ( "${ZSHU[d_conf]}"/**/*.zsh(N.r) ) ; do
        zcompile -UR "$i"
    done
    for i ( "${ZSHU[d_completion]}"/*(N.r) ) ; do
        case "$i" in
        *.zwc )
            ## likely a remnant
            rm -f "$i"
            continue
        ;;
        esac
        zcompile -UR "$i"
        mv -f "$i.zwc" "${ZSHU[d_compzwc]}/"
    done
}

z-zwc-flush() {
    rm -f "${ZSHU[d_conf]}"/**/*.zwc(N.r)
}

z-update() {
    dotfiles-update || return $?
    z-cache-flush
}

z-reload() {
    export ZDOTDIR="${ZSHU[d_zdot]}"
    local r
    exec -a "${ZSH_ARGZERO}" "${ZSH_NAME}" "${argv[@]}"
    r=$?
    echo "unable to reload (something went wrong), code $r" >&2
    return $r
}

## reload or new session are required to regenerate compcache
z-cache-flush() {
    find "${ZSHU[d_cache]}/" -xdev -type f '!' -name '.keep' -delete
    find "${ZSHU[d_zdot]}/.config/zsh.dots/" -xdev -type f '!' -name '.zshenv' -delete
    z-zwc-flush
    z-zwc-gen
}
