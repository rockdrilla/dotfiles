#!/bin/sh
set -f -e
set -o noglob errexit

gh_repo='rockdrilla/dotfiles'
gh_br='main'

f_gitignore='.config/dotfiles/gitignore'
u_gitignore="https://raw.githubusercontent.com/${gh_repo}/${gh_br}/${f_gitignore}"

u_repo="https://github.com/${gh_repo}.git"
d_repo='.config/dotfiles/repo.git'

u_tarball="https://github.com/${gh_repo}/archive/refs/heads/${gh_br}.tar.gz"

main() {
    ## dry run to test connectivity
    curl -sSL "${u_gitignore}" >/dev/null

    umask 0077

    if git_avail ; then
        if [ -s "${HOME}/${d_repo}/info/refs" ] ; then
            dot_update
        else
            dot_install
        fi
    else
        echo 'git is missing, proceed "raw" installation.'
        dot_install_raw
    fi

    echo 'installed.'
}

git_avail() {
    command git --version >/dev/null 2>/dev/null
}

dot_install() {
    backup_unconditionally
    git_env
    mkdir -p "${GIT_DIR}"
    git init -b ${gh_br}
    git_config
    git_update
}

dot_update() {
    git_env
    git_update
}

dot_install_raw() {
    tf_tar=$(mktemp)
    curl -sSL "${u_tarball}" > "${tf_tar}"

    td_tree=$(mktemp -d)

    if ! tar_try_extract "${tf_tar}" "${td_tree}" "${f_gitignore}" ; then
        rm -rf "${tf_tar}" "${td_tree}"
        exit 1
    fi
    rm -f "${tf_tar}"

    tf_list=$(mktemp)
    curl -sSL "${u_gitignore}" | \
    sed -En '/^!\/(.+)$/{s//\1/;p;}' > "${tf_list}"

    td_backup=$(mktemp -d)
    while read f ; do
        if [ -f "${HOME}/$f" ] ; then
            if cmp_files "${td_tree}" "${HOME}" "$f" ; then
                continue
            fi
            d=$(dirname "$f")
            if [ -n "$d" ] ; then
                mkdir -p "${td_backup}/$d"
            fi
            cat < "${HOME}/$f" > "${td_backup}/$f"
        fi
    done < "${tf_list}"
    rm -f "${tf_list}"

    tar -C "${td_tree}" -cf . - | tar -C "${HOME}" -xf -
    rm -rf "${td_tree}"

    n_bak=$(find "${td_backup}/" -mindepth 1 | wc -l)
    if [ "${n_bak}" != 0 ] ; then
        echo "backed-up files are here: ${td_backup}/"
        find "${td_backup}/" -mindepth 1 -ls
    else
        rmdir "${td_backup}"
    fi
}

git_env() {
    GIT_DIR="${HOME}/${d_repo}"
    GIT_WORK_TREE="${HOME}"
    export GIT_DIR GIT_WORK_TREE
}

git_config() {
    ## remote
    git remote add origin "${u_repo}"
    git config remote.origin.fetch "+refs/heads/${gh_br}:refs/remotes/origin/${gh_br}"
    git config remote.origin.tagopt '--no-tags'
    git config "branch.${gh_br}.remote" origin
    ## repo-specific
    git config core.worktree "${GIT_WORK_TREE}"
    git config core.excludesfile "${f_gitignore}"
    ## generic
    git config gc.auto 0
    git config pull.ff only
    git config receive.denyNonFastForwards true
}

git_update() {
    git remote update -p
    git pull
    git gc --aggressive --prune=all --force
}

tar_test() {
    tar --wildcards -tf "$@" >/dev/null 2>/dev/null
}

tar_try_extract() {
    if tar_test "$1" "$3" ; then
        tar -C "$2" -xf "$2"
        return
    fi
    opt='--strip-components=1'
    if tar_test "$1" ${opt} "*/$3" ; then
        tar -C "$2" ${opt} -xf "$2"
        return
    fi
    return 1
}

cmp_files() {
    cmp -s "$1/$3" "$2/$3" >/dev/null 2>/dev/null
}

backup_unconditionally() {
    tf_list=$(mktemp)
    curl -sSL "${u_gitignore}" | \
    sed -En '/^!\/(.+)$/{s//\1/;p;}' > "${tf_list}"

    td_backup=$(mktemp -d)
    while read f ; do
        if [ -f "${HOME}/$f" ] ; then
            d=$(dirname "$f")
            if [ -n "$d" ] ; then
                mkdir -p "${td_backup}/$d"
            fi
            mv -f "${HOME}/$f" "${td_backup}/$f"
        fi
    done < "${tf_list}"
    rm -f "${tf_list}"

    n_bak=$(find "${td_backup}/" -mindepth 1 | wc -l)
    if [ "${n_bak}" != 0 ] ; then
        echo "backed-up files are here: ${td_backup}/"
        find "${td_backup}/" -mindepth 1 -ls
    else
        rmdir "${td_backup}"
    fi
}

main "$@"
