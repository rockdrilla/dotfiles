#!/bin/sh
set -f -e 
set -o noglob errexit

GIT_OPTIONAL_LOCKS=0
export GIT_OPTIONAL_LOCKS

path_gitignore='.config/dotfiles/gitignore'

gen_gitignore() {
    git rev-parse --git-dir >/dev/null 2>/dev/null
    {
        echo '*'
        git ls-files | sed -E 's:^:!/:'
    } > "$1"
    exit 0
}

me=$(readlink -e "$0")
topdir=$(printf '%s' "${me}" | sed -E 's:/[^/]+/[^/]+/[^/]+$::')
cd "${topdir}"

## end-point installation
dir=$(dirname "${me}")'/repo.git'
if [ -s "${dir}/packed-refs" ] ; then
    GIT_DIR="${dir}"
    GIT_WORK_TREE="${topdir}"
    export GIT_DIR GIT_WORK_TREE
    gen_gitignore "${GIT_WORK_TREE}/${path_gitignore}" || true
fi

## development tree
if [ -s '.git/packed-refs' ] ; then
    gen_gitignore "${path_gitignore}" || true
fi

exit 1
