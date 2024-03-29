#!/bin/zsh

z-ssh-agent() {
    while : ; do
        [ -n "${SSH_AGENT_PID}" ] || break
        z-proc-exists "${SSH_AGENT_PID}" || break

        [ -n "${SSH_AUTH_SOCK}" ] || break
        [ -S "${SSH_AUTH_SOCK}" ] || break

        ## don't bother with ssh agent socket if it already set
        return 0

        break
    done
    [ -z "${SSH_AGENT_PID}" ] || kill "${SSH_AGENT_PID}"
    unset SSH_AGENT_PID

    (( ${+commands[ssh-agent]} )) || return 127

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

    local pid_file
    pid_file="${SSH_AUTH_SOCK:h}/ssh-agent.pid"
    while : ; do
        [ -s "${pid_file}" ] || break
        SSH_AGENT_PID=$(cat "${pid_file}")
        z-proc-exists "${SSH_AGENT_PID}" || break
        [ -S "${SSH_AUTH_SOCK}" ] || break

        ## don't bother with ssh agent socket if it already set
        export SSH_AGENT_PID SSH_AUTH_SOCK
        return 0
    done
    unset SSH_AGENT_PID

    if [ -S "${SSH_AUTH_SOCK}" ] ; then
        rm -fv "${SSH_AUTH_SOCK}"
    fi

    {
        eval "$(ssh-agent -s -a "${SSH_AUTH_SOCK}")"
    } >/dev/null

    while : ; do
        [ -n "${SSH_AGENT_PID}" ] || break
        [ -n "${SSH_AUTH_SOCK}" ] || break
        [ -S "${SSH_AUTH_SOCK}" ] || break

        echo "${SSH_AGENT_PID}" > "${pid_file}"
        export SSH_AGENT_PID SSH_AUTH_SOCK
        return 0
    done

    unset SSH_AGENT_PID SSH_AUTH_SOCK
    return 1
}
