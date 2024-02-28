#!/bin/zsh

dotfiles-update() {
    "${ZSHU[d_dotfiles]}/install.sh" "$@"
}

dotfiles-git() { (
    cd "${ZSHU[d_zdot]}/"
    set -a
    GIT_DIR="${ZSHU[d_dotfiles]}/repo.git"
    GIT_WORK_TREE="${ZSHU[d_zdot]}"
    set +a
    z-reload
) }

dotfiles-gen-gitignore() {
    local x='.config/dotfiles/gen-gitignore.sh'
    [ -x "$x" ] || {
        echo "${x:t} is somewhere else" >&2
        return 1
    }
    if [ -d .config/dotfiles/repo.git ] ; then
        echo "NOT going to change dotfiles installation" >&2
        return 1
    fi
    "$x" "$@"
}

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
    export ZDOTDIR="${ZSHU[d_zdot]}"
    exec -a "${ZSH_ARGZERO}" "${ZSH_NAME}" "${argv[@]}"
    echo "unable to reload (something went wrong), code $?" >&2
    return 1
}

## reload or new session are required to regenerate compcache
z-cache-flush() {
    find "${ZSHU[d_cache]}/" -xdev -type f '!' -name '.keep' -delete
    find "${ZSHU[d_zdot]}/.config/zsh.dots/" -xdev -type f '!' -name '.zshenv' -delete
    z-zwc-flush
    z-zwc-gen
}
