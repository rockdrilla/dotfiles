#!/bin/sh
set -ef

uri_krdsh="${GITKRDSH:-https://git.krd.sh/krd}/dotfiles"
uri_github="${GITHUB:-https://github.com/rockdrilla}/dotfiles"

git_branch='main'

d_repo='.config/dotfiles/repo.git'
f_gitignore='.config/dotfiles/gitignore'

have_cmd() {
    command -v "$1" >/dev/null 2>&1 || return $?
}

fetch() {
    if have_cmd curl ; then
        curl -sSL ${2:+ -o "$2" } "$1" || return $?
        return 0
    fi
    if have_cmd wget ; then
        if [ -n "$2" ] ; then
            wget -q -O - "$1" > "$2" || return $?
        else
            wget -q -O - "$1" || return $?
        fi
        return 0
    fi
    x=/usr/lib/apt/apt-helper
    if have_cmd $x ; then
        if [ -n "$2" ] ; then
            $x download-file "$1" "$2" || return $?
            return 0
        fi
        __fetch_t=$(mktemp) || return 1
        set +e
        (
            set -e
            $x download-file "$1" "${__fetch_t}" || return $?
            cat "${__fetch_t}"
        )
        __fetch_r=$?
        rm -f "${__fetch_t}" ; unset __fetch_t
        return ${__fetch_r}
    fi
    echo 'no method is available to fetch URLs' >&2
    return 1
}

select_forge() {
    unset uri_gitignore uri_repo uri_tarball
    ## try with git.krd.sh
    t_gitignore="${uri_krdsh}/raw/branch/${git_branch}/${f_gitignore}"
    if fetch "${t_gitignore}" >/dev/null ; then
        uri_repo="${uri_krdsh}.git"
        uri_gitignore="${t_gitignore}"
        uri_tarball="${uri_krdsh}/archive/${git_branch}.tar.gz"
        unset t_gitignore
        return
    fi
    ## try with github.com
    t_gitignore="${uri_github}/raw/${git_branch}/${f_gitignore}"
    if fetch "${t_gitignore}" >/dev/null ; then
        uri_repo="${uri_github}.git"
        uri_gitignore="${t_gitignore}"
        uri_tarball="${uri_github}/archive/refs/heads/${git_branch}.tar.gz"
        unset t_gitignore
        return
    fi
    echo 'no forge is available to fetch URLs' >&2
    return 1
}

main() {
    ## test connectivity and select forge
    select_forge

    umask 0077

    if have_cmd git ; then
        if [ -s "${HOME}/${d_repo}/HEAD" ] ; then
            dot_update
        else
            dot_install
        fi
    else
        echo 'git is missing, proceed "raw" installation.' >&2
        dot_install_raw
    fi

    propagate_dist_files

    echo 'installed.' >&2
}

dot_install() {
    backup_unconditionally
    git_env
    mkdir -p "${GIT_DIR}"
    git init
    git branch -M "${git_branch}" || true
    git_config_init
    git_update
}

dot_update() {
    git_env
    git_update
}

find_fast() {
    find "$@" -printf . -quit | grep -Fq .
}

dot_install_raw() {
    tf_tar=$(mktemp)
    fetch "${uri_tarball}" "${tf_tar}"

    td_tree=$(mktemp -d)

    if ! tar_try_extract "${tf_tar}" "${td_tree}" "${f_gitignore}" ; then
        rm -rf "${tf_tar}" "${td_tree}"
        exit 1
    fi
    rm -f "${tf_tar}"

    tf_list=$(mktemp)
    fetch "${uri_gitignore}" \
    | sed -En '/^!\/(.+)$/{s//\1/;p;}' \
    > "${tf_list}"

    td_backup=$(mktemp -d)
    while read -r f ; do
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
    rm -f "${tf_list}" ; unset tf_list

    tar -C "${td_tree}" -cf . - | tar -C "${HOME}" -xf -
    rm -rf "${td_tree}"

    if find_fast "${td_backup}/" -mindepth 1 ; then
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

git_config_init() {
    ## remote
    git remote add origin "${uri_repo}"
    git config remote.origin.fetch "+refs/heads/${git_branch}:refs/remotes/origin/${git_branch}"
    git config remote.origin.tagopt '--no-tags'
    git config "branch.${git_branch}.remote" origin
    ## repo-specific
    git config core.worktree "${GIT_WORK_TREE}"
    git config core.excludesfile "${f_gitignore}"
}

git_config() {
    ## repo-specific
    git remote set-url origin "${uri_repo}"
    git config core.attributesfile .config/dotfiles/gitattributes
    ## migration (remove later)
    git config --unset gc.auto || :
    git config --unset pull.ff || :
    ## size optimization
    git config core.compression 9
    git config pack.compression 9
    ## generic
    git config receive.denyNonFastForwards true
}

git_update() {
    git_config
    git remote update -p
    git pull || git reset --hard "origin/${git_branch}"
    git gc --aggressive --prune=all --force || git gc || true
}

tar_test() {
    tar --wildcards -tf "$@" >/dev/null 2>&1
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
    cmp -s "$1/$3" "$2/$3" >/dev/null 2>&1
}

backup_unconditionally() {
    tf_list=$(mktemp)
    fetch "${uri_gitignore}" \
    | sed -En '/^!\/(.+)$/{s//\1/;p;}' \
    > "${tf_list}"

    td_backup=$(mktemp -d)
    while read -r f ; do
        if [ -f "${HOME}/$f" ] ; then
            d=$(dirname "$f")
            if [ -n "$d" ] ; then
                mkdir -p "${td_backup}/$d"
            fi
            mv -f "${HOME}/$f" "${td_backup}/$f"
        fi
    done < "${tf_list}"
    rm -f "${tf_list}" ; unset tf_list

    if find_fast "${td_backup}/" -mindepth 1 ; then
        echo "backed-up files are here: ${td_backup}/"
        find "${td_backup}/" -mindepth 1 -ls
    else
        rmdir "${td_backup}"
    fi
}

propagate_dist_files() {
    tf_list=$(mktemp)
    sed -En '/^!\/(.+\.dist)$/{s//\1/;p;}' < "${HOME}/${f_gitignore}" > "${tf_list}"

    while read -r f_dist ; do
        [ -n "${f_dist}" ] || continue
        [ -f "${f_dist}" ] || continue

        f=${f_dist%.dist}
        if [ -f "$f" ] ; then continue ; fi

        cp "${f_dist}" "$f"
    done < "${tf_list}"
    rm -f "${tf_list}" ; unset tf_list
}

main "$@"
