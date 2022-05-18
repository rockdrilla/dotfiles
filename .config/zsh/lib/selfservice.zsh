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
}

z-reload() {
    exec -a "${ZSH_ARGZERO}" "${ZSH_NAME}" "${argv[@]}"
    echo "unable to reload (something went wrong), code $?" 1>&2
}

## reload or new session are required to regenerate compcache
z-cache-flush() {
    find "${ZSHU[d_cache]}/" -xdev -mindepth 1 -type f '!' -name '.keep' -delete
}
