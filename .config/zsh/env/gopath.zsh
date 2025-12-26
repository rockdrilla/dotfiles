#!/bin/zsh

z-gobin-fixup() {
    z-have-cmd go || return 0

    local gobin
    gobin=$(command go env GOBIN)
    if [ -z "${gobin}" ] ; then
        local gopath
        gopath=$(command go env GOPATH)
        [ -n "${gopath}" ] || return 1
        [ -d "${gopath}" ] || return 0
        gobin="${gopath}/bin"
    fi
    [ -d "${gobin}" ] || mkdir "${gobin}" || return 1
    ## already in PATH?
    [ "${path[(I)${gobin}]}" = 0 ] || return 0
    path=( "${gobin}" ${path} )
}
