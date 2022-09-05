#!/bin/zsh

dotfiles-update() {
    "${ZSHU[d_zdot]}/.config/dotfiles/install.sh"
}

dotfiles-git() { (
    cd "${ZSHU[d_zdot]}/"
    export GIT_DIR="${ZSHU[d_zdot]}/.config/dotfiles/repo.git"
    export GIT_WORK_TREE="${ZSHU[d_zdot]}"
    zsh -i
) }

z-update() {
    dotfiles-update
    for i ( $(find "${ZSHU[d_conf]}/" -xdev -type f -name '*.zsh') ) ; do
        zcompile -U "$i"
    done ; unset i
}

z-reload() {
    exec -a "${ZSH_ARGZERO}" "${ZSH_NAME}" "${argv[@]}"
    echo "unable to reload (something went wrong), code $?" 1>&2
}

## reload or new session are required to regenerate compcache
z-cache-flush() {
    find "${ZSHU[d_cache]}/" "${ZSHU[d_compcache]}/" -xdev -type f '!' -name '.keep' -delete
    find "${ZSHU[d_conf]}/" -xdev -type f -name '*.zwc' -delete
}
