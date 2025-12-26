#!/bin/zsh

z-gpg-agent-is-ssh-agent() {
    if [ -n "${GPG_AGENT_IS_SSH_AGENT}" ] ; then
        case "${GPG_AGENT_IS_SSH_AGENT}" in
        1 ) return 0 ;;
        * ) return 1 ;;
        esac
    fi

    local x
    x=$(z-gpgconf-getopt gpg-agent enable-ssh-support) || return ?
    [ -n "$x" ] || x=0

    typeset -g -x GPG_AGENT_IS_SSH_AGENT="$x"
    [ "$x" = 1 ] || return 1
}

z-gpg-agent-pid() {
    if [ "${ZSHU_RUN[systemd]}" = 1 ] ; then
        local a=1 u _pid
        for u in gpg-agent.{service,socket} ; do
            z-systemctl-quiet --user is-active $u || a=0
            [ "$a" = 1 ] || break
        done
        [ "$a" = 1 ] || return 1

        _pid=$(z-systemctl-get-pid gpg-agent.service --user) || return 1
        echo "${_pid}"
    else
        local a b c _pid
        while read -rs a b c ; do
            case "$a" in
            D ) _pid=$b ;;
            OK ) ;;
            * ) _pid= ;;
            esac
        done <<< "$(gpg-connect-agent --no-autostart <<< 'GETINFO pid' 2>/dev/null || : )"
        [ -n "${_pid}" ] || return 1
        z-proc-exists "${_pid}" || return 1

        echo "${_pid}"
    fi
}

z-gpg-agent-is-running() {
    z-gpg-agent-pid >/dev/null
}

z-gpg-agent() {
    ## don't bother with gpg agent socket if it already set
    [ -z "${GPG_AGENT_INFO}" ] || return 0

    local with_systemd=0
    if [ "${ZSHU_RUN[systemd]}" = 1 ] ; then
        with_systemd=1

        local u s
        for u in gpg-agent.{service,socket} ; do
            s=$(z-systemctl --user is-enabled $u)
            case "$s" in
            enabled | enabled-runtime | static ) ;;
            * ) with_systemd=0 ;;
            esac
            [ "${with_systemd}" = 1 ] || break
        done
    fi

    local agent_sock
    agent_sock=$(gpgconf --list-dirs agent-socket) || return $?
    [ -n "${agent_sock}" ] || return 1
    typeset -g -x GPG_AGENT_INFO="${agent_sock}:0:1"

    if ! z-gpg-agent-is-running ; then
        if [ "${with_systemd}" = 1 ] ; then
            # z-systemctl --user start gpg-agent.{service,socket}
            z-proc-run-bg systemctl --no-pager --no-ask-password --user start gpg-agent.{service,socket}
        else
            z-proc-run-bg sh -c 'gpgconf --kill gpg-agent ; sleep 0.2 ; gpgconf --launch gpg-agent' 2>/dev/null
        fi
    fi

    z-gpg-agent-is-ssh-agent || return 0

    ## don't bother with ssh agent socket if it's already set
    [ -z "${SSH_AUTH_SOCK}" ] || return 0

    local ssh_auth_sock
    ssh_auth_sock=$(gpgconf --list-dirs agent-ssh-socket) || return $?
    [ -n "${ssh_auth_sock}" ] || return 1
    typeset -g -x SSH_AUTH_SOCK="${ssh_auth_sock}"

    local gpg_agent_pid
    gpg_agent_pid=$(z-gpg-agent-pid)
    if [ -n "${gpg_agent_pid}" ] ; then
        typeset -g -x SSH_AGENT_PID="${gpg_agent_pid}"

        local _file
        _file=$(z-ssh-agent-pid-file)
        printf '%s' "${SSH_AGENT_PID}" > "${_file}"
    fi
}
