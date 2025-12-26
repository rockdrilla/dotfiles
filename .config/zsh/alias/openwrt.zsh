#!/bin/zsh

openwrt-ssh() {
    ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no "$@"
}

openwrt-scp() {
    scp -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no "$@"
}

openwrt-apk-list() {
    z-have-cmd openwrt-apk || {
        echo 'missing "openwrt-apk"' >&2
        return 127
    }

    local i w
    w=$(mktemp -d) ; : "${w:?}"
    for i ; do
        [ -n "$i" ] || continue
        find "$w/" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        find "$w/" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || return
        openwrt-apk extract --no-cache --no-logfile --no-network --no-check-certificate --allow-untrusted --no-chown --destination "$w" "$i"
        env -C "$w" find ./ -mindepth 1 -exec ls -ldgG --color {} +
    done
    rm -rf "$w"
}

openwrt-ipk-list() {
    local i m o
    for i ; do
        [ -n "$i" ] || continue
        o=0
        for m ( './data.tar.gz' 'data.tar.gz' ) ; do
            tar -tf "$i" "$m" 2>/dev/null || continue
            o=1
            env printf '%q:\n' "$i"
            tar -Oxf "$i" "$m" | tar -ztvf -
            break
        done
        if [ "$o" = '0' ] ; then
            env printf '%q: missing data.tar.gz\n' "$i"
            continue
        fi
    done
}
