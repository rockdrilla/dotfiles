#!/bin/sh
set -ef

path_gitignore='.config/dotfiles/gitignore'

gen_gitignore() {
    git rev-parse --git-dir >/dev/null 2>&1
    touch "$1"
    {
        echo '*'
        git ls-files -z | sort -zn | sed -zE 's:^:!/:' | tr '\0' '\n'
    } > "$1"
    exit 0
}

me=$(readlink -e "$0")
topdir=$(printf '%s' "${me}" | sed -zE 's:/[^/]+/[^/]+/[^/]+$::')
cd "${topdir}"

## sync with /.config/dotfiles/scripts/ro-git
export GIT_OPTIONAL_LOCKS=0

dir="${me%/*}/repo.git"
if [ -d "${dir}" ] ; then
    ## end-point installation
    GIT_DIR="${dir}"
    GIT_WORK_TREE="${topdir}"
    export GIT_DIR GIT_WORK_TREE
    gen_gitignore "${GIT_WORK_TREE}/${path_gitignore}"
else
    ## development tree
    gen_gitignore "${path_gitignore}"
fi
