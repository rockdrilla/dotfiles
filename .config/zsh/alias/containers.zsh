#!/bin/zsh

alias bud='buildah bud --isolation chroot --network host --format docker -f '

alias pod-run='podman run -e "TERM=${TERM:-linux}" --network host --rm -it '
alias pod-run-sh="pod-run --entrypoint='[\"/bin/sh\"]' --user=0:0 "
alias pod-ps='podman ps '
alias pod-images='podman images --format "table {{.ID}} {{.Repository}}:{{.Tag}} {{.Size}} {{.Created}} |{{.CreatedAt}}" '
alias pod-inspect='podman inspect '
alias pod-logs='podman logs '

sko-inspect() {
    command skopeo inspect "docker://${1:?}"
}

sko-list-tags() {
    command skopeo list-tags "docker://${1:?}"
}

pod-dive() {
    command dive "podman://${1:?}"
}

jq-visual() {
    jq -C | less
}

jq-config() {
    jq '.[].Config'
}

jq-tags() {
    jq -r '.Tags[]'
}

if [ ${UID} -ne 0 ] ; then
    alias docker='sudo docker '
fi
alias dkr='docker '
alias dkr-run='dkr run -e "TERM=${TERM:-linux}" --network host --rm -it '
alias dkr-run-sh="dkr-run --entrypoint='' --user=0:0 "
alias dkr-ps='dkr ps '
alias dkr-images='dkr images --format "table {{.ID}}\\t{{.Repository}}:{{.Tag}}\\t{{.Size}}\\t{{.CreatedAt}}" '
alias dkr-inspect='dkr inspect '
alias dkr-logs='dkr logs '
