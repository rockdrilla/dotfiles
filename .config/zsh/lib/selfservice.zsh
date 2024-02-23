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

z-zwc-gen() {
    local i
    for i ( "${ZSHU[d_conf]}"/**/*.zsh(N.r) ) ; do
        zcompile -UR "$i"
    done
    # for i ( "${ZSHU[d_completion]}"/*(N.r) ) ; do
    #     case "$i" in
    #     *.zwc )
    #         # likely a remnant
    #         rm -f "$i"
    #         continue
    #     ;;
    #     esac
    #     zcompile -UR "$i"
    #     mv -f "$i.zwc" "${ZSHU[d_compzwc]}/"
    # done
}

z-zwc-flush() {
    rm -f "${ZSHU[d_conf]}"/**/*.zwc(N.r)
}

z-update() {
    dotfiles-update
    z-cache-flush
}

z-reload() {
    exec -a "${ZSH_ARGZERO}" "${ZSH_NAME}" "${argv[@]}"
    echo "unable to reload (something went wrong), code $?" 1>&2
    return 1
}

## reload or new session are required to regenerate compcache
z-cache-flush() {
    find "${ZSHU[d_cache]}/" -xdev -type f '!' -name '.keep' -delete
    z-zwc-flush
    z-zwc-gen
}
