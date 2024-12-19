#!/bin/zsh

z-gpg-agent() {
    ## don't bother with gpg agent socket if it already set
    [ -z "${GPG_AGENT_INFO}" ] || return 0

    (( ${+commands[gpg-agent]} )) || return 127

    if (( ${+commands[systemctl]} )) ; then
        local u s
        for u in gpg-agent.{service,socket} ; do
            s=$(z-systemctl --user is-enabled $u)
            case "$s" in
            disabled ) ;;
            * ) continue ;;
            esac
            z-systemctl --user --now enable $u
        done
    fi

    (( ${+commands[gpgconf]} )) || return 127

    local agent_sock
    agent_sock=$(command gpgconf --list-dirs agent-socket) || return $?
    [ -n "${agent_sock}" ] || return 3
    export GPG_AGENT_INFO="${agent_sock}:0:1"

    ## don't bother with ssh agent socket if it already set
    [ -z "${SSH_AUTH_SOCK}" ] || return 0

    local want_ssh_agent ssh_auth_sock
    want_ssh_agent=$(z-gpgconf-getopt gpg-agent enable-ssh-support)
    if [ "${want_ssh_agent}" = 1 ] ; then
        ssh_auth_sock=$(command gpgconf --list-dirs agent-ssh-socket) || return $?
        [ -n "${ssh_auth_sock}" ] || return 5
        export SSH_AUTH_SOCK="${ssh_auth_sock}"
    fi
}
