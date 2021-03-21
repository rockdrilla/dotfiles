#!/bin/zsh

__z_curl_headers() {
    command curl -qsI "$@" 2>/dev/null
}
__z_curl_location() {
    __z_curl_headers "$1" \
    | sed -En '/^[Ll]ocation: (.+)$/{s//\1/;p}'
}
__z_curl_response() {
    __z_curl_headers -L "$1" \
    | sed -En '/^HTTP\/[0-9.]+ ([1-5][0-9]{2})( .+)?$/{s//\1/;p}' \
    | tail -n 1
}
