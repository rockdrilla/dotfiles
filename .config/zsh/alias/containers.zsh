#!/bin/zsh

typeset -g -aU ZSHU_CNTR_SHELLS=( /bin/bash /bin/sh /bin/ash )
typeset -g -a ZSHU_CNTR_FALLBACK_SHELL=( /busybox/busybox sh )

alias bud='buildah bud --network=host -f '

function {
    local i
    for i ( run images ps top inspect logs ) ; do
        alias "pod-$i"="podman $i "
    done
}

z-pod() { command podman "$@" ; }

alias podman='z-podman '
z-podman() {
    case "${1:-}" in
    run )    shift ; z-pod-run "$@" ;;
    images ) shift ; z-pod-images "$@" ;;
    ps )     shift ; z-pod-ps "$@" ;;
    top )    shift ; z-pod-top "$@" ;;
    * ) z-pod "$@" ;;
    esac
}

z-pod-run() {
    z-pod run -e "TERM=${TERM:-linux}" --rm -it "$@"
}

z-pod-images() {
    local have_flags=0
    case "$1" in
    -* ) have_flags=1 ;;
    esac
    if [ ${have_flags} = 1 ] ; then
        z-pod images "$@"
        return $?
    fi
    z-pod images --format 'table {{.ID}} {{.Repository}}:{{.Tag}} {{.Size}} {{.Created}} |{{.CreatedAt}}' "$@"
}

z-pod-ps() {
    local have_flags=0
    case "$1" in
    -* ) have_flags=1 ;;
    esac
    if [ ${have_flags} = 1 ] ; then
        z-pod ps "$@"
        return $?
    fi
    z-pod ps -a --sort names --format 'table {{.ID}} {{.Names}} {{.Image}} {{.CreatedHuman}} {{.Status}}' "$@"
}

z-pod-top() {
    local have_flags=0
    case "$1" in
    -* ) have_flags=1 ;;
    esac
    if [ ${have_flags} = 1 ] ; then
        z-pod top "$@"
        return $?
    fi
    if [ $# -eq 1 ] ; then
        z-pod top "$1" 'pid,ppid,user,args,pcpu,time,stime,etime,state,nice,rss,vsz'
    else
        z-pod top "$@"
    fi
}

pod-images-grep() {
    z-pod-images \
    | {
        if [ -z "$1" ] ; then
            head
        else
            sed -En "1{p;D};\\${ZSHU_XSED}$1${ZSHU_XSED}p"
        fi
    }
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
    break;done
    if [ -z "${shell}" ] ; then
        echo "unable to run: $*"
        return 1
    fi
    z-pod-run ${cntr_opts[@]} "$@" ${shell[@]}
}

## NB: naive. rewrite!
sko-inspect() {
    local i
    i="${1:?}" ; shift
    command skopeo inspect "$@" "docker://$i"
}

## NB: naive. rewrite!
sko-list-tags() {
    local i
    i="${1:?}" ; shift
    command skopeo list-tags "$@" "docker://$i"
}

## NB: naive. rewrite!
pod-dive() {
    local i
    i="${1:?}" ; shift
    dive "$@" "podman://$i"
}

jq-visual() { jq -C | "${PAGER:-cat}" ; }
jq-config() { jq '.[].Config' ; }
jq-tags() { jq -r '.Tags[]' ; }

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
    break;done
    if [ -z "${shell}" ] ; then
        echo "unable to run: $*"
        return 1
    fi
    z-dkr-run ${cntr_opts[@]} "$@" ${shell[@]}
}

## NB: naive. rewrite!
dkr-dive() {
    local i
    i="${1:?}" ; shift
    dive "$@" "docker://$i"
}

typeset -g ZSHU_GRP_DOCKER=docker
z-adjust-docker() {
    [ ${UID} -eq 0 ] && return 0

    getent group "${ZSHU_GRP_DOCKER}" >/dev/null || return 1
    z-have-cmd docker || return 127

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

    z-have-cmd sudo || return 127

    alias docker='sudo docker '
    z-dkr() { command sudo docker "$@" ; }
    return 0
}
