#!/bin/zsh

z-ssh-agent-pid-file() {
    [ -n "${SSH_AUTH_SOCK}" ] || return 1
    echo "${SSH_AUTH_SOCK:h}/ssh-agent.pid"
}

z-ssh-agent-pid() {
    if [ "${ZSHU_RUN[systemd]}" = 1 ] ; then
        local a=1 u _pid
        for u in ssh-agent.{service,socket} ; do
            [ "$a" = 1 ] || break
            z-systemctl-quiet --user is-active $u || a=0
        done
        [ "$a" = 1 ] || return 1

        _pid=$(z-systemctl-get-pid ssh-agent.service --user) || return 1
        echo "${_pid}"
    else
        [ -n "${SSH_AUTH_SOCK}" ] || return 1

        local _file _pid
        _file=$(z-ssh-agent-pid-file)
        [ -s "${_file}" ] || return 1
        _pid=$(cat "${_file}") || return 1
        z-proc-exists "${_pid}" || return 1

        echo "${_pid}"
    fi
}

z-ssh-agent-is-running() {
    z-ssh-agent-pid >/dev/null
}

z-ssh-agent() {
    ## is gpg-agent already handling these?
    if z-gpg-agent-is-ssh-agent ; then return 0 ; fi

    while : ; do
        [ -n "${SSH_AUTH_SOCK}" ] || break
        [ -S "${SSH_AUTH_SOCK}" ] || break

        if [ -n "${SSH_AGENT_PID}" ] ; then
            z-proc-exists "${SSH_AGENT_PID}" || break
        fi

        ## don't bother with ssh agent socket if it already set
        return 0
    break;done

    local with_systemd=0
    if [ "${ZSHU_RUN[systemd]}" = 1 ] ; then
        with_systemd=1

        local u s
        for u in ssh-agent.{service,socket} ; do
            s=$(z-systemctl --user is-enabled $u)
            case "$s" in
            enabled | enabled-runtime | static ) ;;
            * ) with_systemd=0 ;;
            esac
            [ "${with_systemd}" = 1 ] || break
        done
    fi

    if [ "${with_systemd}" = 0 ] ; then
        [ -z "${SSH_AGENT_PID}" ] || z-proc-run-bg kill "${SSH_AGENT_PID}"
        unset SSH_AGENT_PID

        [ -z "${SSH_AUTH_SOCK}" ] || rm -fv "${SSH_AUTH_SOCK}"
        unset SSH_AUTH_SOCK
    fi

    if [ "x${with_systemd}x${SSH_AUTH_SOCK}x" = 'x1xx' ] ; then
        local type value _first _sock
        while read -rs type value ; do
            [ -z "${_sock}" ] || break
            [ -n "${_first}" ] || _first="${value}"
            if [ "${type}" = Stream ] ; then
                case "${value}" in
                /* ) _sock="${value}" ;;
                esac
            fi
        done <<< "$(z-systemctl-get-listen ssh-agent.socket --user)"

        [ -n "${_sock}" ] || _sock="${_first}"
        [ -n "${_sock}" ] || return 1
    fi

    if [ -z "${SSH_AUTH_SOCK}" ] ; then
        local sock_dir
        if [ "${XDG_RUNTIME_DIR}" = "${TMPDIR}" ] ; then
            sock_dir="${ZSHU[d_zdot]}/.cache/ssh"
        else
            sock_dir="${XDG_RUNTIME_DIR}/ssh"
        fi
        mkdir -p "${sock_dir}"
        SSH_AUTH_SOCK="${sock_dir}/ssh-agent.sock"
    fi

    [ -n "${SSH_AUTH_SOCK}" ] || return 1

    if ! z-ssh-agent-is-running ; then
        if [ "${with_systemd}" = 1 ] ; then
            # z-systemctl --user start ssh-agent.{service,socket}
            z-proc-run-bg systemctl --no-pager --no-ask-password --user start ssh-agent.{service,socket}
        else
            ## run "ssh-agent" and try to fetch it's pid
            SSH_AGENT_PID=$(ssh-agent -s -a "${SSH_AUTH_SOCK}" | sed -zEn '/^.*[;[:space:]]SSH_AGENT_PID=([0-9]+)[;[:space:]].*$/{s//\1/p;q}')
        fi
    fi

    local pid_file
    pid_file=$(z-ssh-agent-pid-file)

    if [ "${with_systemd}" = 1 ] ; then
        SSH_AGENT_PID=$(z-ssh-agent-pid)
    fi

    while [ -n "${SSH_AGENT_PID}" ] ; do
        z-proc-exists "${SSH_AGENT_PID}" || break

        echo "${SSH_AGENT_PID}" > "${pid_file}"

        typeset -g -x SSH_AGENT_PID SSH_AUTH_SOCK
        return 0
    break;done

    unset SSH_AGENT_PID SSH_AUTH_SOCK
    return 1
}
