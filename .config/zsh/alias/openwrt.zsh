#!/bin/zsh

openwrt-apk-list() {
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
