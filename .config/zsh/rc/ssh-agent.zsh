#!/bin/zsh

z-ssh-agent() {
    while [ -n "${SSH_AGENT_PID}" ] ; do
        z-proc-exists "${SSH_AGENT_PID}" || break

        ## don't bother with ssh agent socket if it already set
        [ -z "${SSH_AUTH_SOCK}" ] || return 0

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

    {
        eval "$(ssh-agent -s -a "${SSH_AUTH_SOCK}")"
    } >/dev/null
}
