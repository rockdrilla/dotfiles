#!/bin/zsh

alias bud='buildah bud --isolation chroot --network host --format docker -f '

alias pod-run='podman run -e "TERM=${TERM:-linux}" --rm -it '
alias pod-images='podman images --format "table {{.ID}} {{.Repository}}:{{.Tag}} {{.Size}} {{.Created}} |{{.CreatedAt}}" '
alias pod-inspect='podman inspect '
alias pod-logs='podman logs '

typeset -Uga ZSHU_CNTR_SHELLS=( /bin/bash /bin/sh /bin/ash )
typeset -ga ZSHU_CNTR_FALLBACK_SHELL=( /busybox/busybox sh )

z-pod() { command podman "$@" ; }

z-pod-run() {
    z-pod run -e "TERM=${TERM:-linux}" --rm -it "$@"
}

## NB: naive. rewrite!
pod-run-sh() {
    local -a cntr_opts=( --network=host --entrypoint='[]' --user=0:0 )
    local i
    local -a shell
    for i ( ${ZSHU_CNTR_SHELLS} ) ; do
        echo "pod-run-sh: trying $i as shell" >&2
        z-pod-run ${cntr_opts[@]} "$@" "$i" -c ':' 2>/dev/null || continue
        shell=($i) ; break
    done
    while [ -z "${shell}" ] ; do
        echo "pod-run-sh: trying '${ZSHU_CNTR_FALLBACK_SHELL[*]}' as last-resort shell" >&2
        z-pod-run ${cntr_opts[@]} "$@" ${ZSHU_CNTR_FALLBACK_SHELL[@]} -c ':' 2>/dev/null || break
        shell=(${ZSHU_CNTR_FALLBACK_SHELL})
        break
    done
    if [ -z "${shell}" ] ; then
        echo "unable to run: $*"
        return 1
    fi
    z-pod-run ${cntr_opts[@]} "$@" ${shell[@]}
}

pod-ps() {
    [ $# -ne 0 ] || set -- -a --format 'table {{.ID}} {{.Names}} {{.Image}} {{.CreatedHuman}} {{.Status}}'
    command podman ps "$@"
}

sko-inspect() {
    local i
    i="${1:?}" ; shift
    command skopeo inspect "$@" "docker://$i"
}

sko-list-tags() {
    local i
    i="${1:?}" ; shift
    command skopeo list-tags "$@" "docker://$i"
}

pod-dive() {
    local i
    i="${1:?}" ; shift
    command dive "$@" "podman://$i"
}

jq-visual() {
    command jq -C | less
}

jq-config() {
    command jq '.[].Config'
}

jq-tags() {
    command jq -r '.Tags[]'
}

alias dkr='docker '
alias dkr-run='dkr run -e "TERM=${TERM:-linux}" --rm -it '
alias dkr-ps='dkr ps '
alias dkr-images='dkr images --format "table {{.ID}}\\t{{.Repository}}:{{.Tag}}\\t{{.Size}}\\t{{.CreatedAt}}" '
alias dkr-inspect='dkr inspect '
alias dkr-logs='dkr logs '

z-dkr() { command docker "$@" ; }

z-dkr-run() {
    z-dkr run -e "TERM=${TERM:-linux}" --rm -it "$@"
}

## NB: naive. rewrite!
dkr-run-sh() {
    local -a cntr_opts=( --network=host --entrypoint='' --user=0:0 )
    local i
    local -a shell
    for i ( ${ZSHU_CNTR_SHELLS} ) ; do
        echo "dkr-run-sh: trying $i as shell" >&2
        z-dkr-run ${cntr_opts[@]} "$@" "$i" -c ':' 2>/dev/null || continue
        shell=($i) ; break
    done
    while [ -z "${shell}" ] ; do
        echo "dkr-run-sh: trying '${ZSHU_CNTR_FALLBACK_SHELL[*]}' as last-resort shell" >&2
        z-dkr-run ${cntr_opts[@]} "$@" ${ZSHU_CNTR_FALLBACK_SHELL[@]} -c ':' 2>/dev/null || break
        shell=(${ZSHU_CNTR_FALLBACK_SHELL})
        break
    done
    if [ -z "${shell}" ] ; then
        echo "unable to run: $*"
        return 1
    fi
    z-dkr-run ${cntr_opts[@]} "$@" ${shell[@]}
}

dkr-dive() {
    local i
    i="${1:?}" ; shift
    command dive "$@" "docker://$i"
}

typeset -ga ZSHU_GRP_DOCKER=docker
z-adjust-docker() {
    [ ${UID} -eq 0 ] && return 0

    getent group "${ZSHU_GRP_DOCKER}" >/dev/null || return 1
    (( ${+commands[docker]} )) || return 127

    local _users=$(getent group "${ZSHU_GRP_DOCKER}" | cut -d: -f4)
    local -a users=("${(@s[,])_users}")
    local i found
    for i ( ${users}) ; do
        if [ "$i" = "${USERNAME}" ] ; then
            found=1
            break
        fi
    done
    [ -n "${found}" ] && return 0

    (( ${+commands[sudo]} )) || return 127

    alias docker='sudo docker '
    z-dkr() { command sudo docker "$@" ; }
    return 0
}
