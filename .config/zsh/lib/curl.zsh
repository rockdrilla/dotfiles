#!/bin/zsh

z_curl_headers() {
    command curl -qsI "$@" 2>/dev/null
}
z_curl_location() {
    z_curl_headers "$1" \
    | sed -En '/^[Ll]ocation: (.+)$/{s//\1/;p}'
}
z_curl_response() {
    z_curl_headers -L "$1" \
    | sed -En '/^HTTP\/[0-9.]+ ([1-5][0-9]{2})( .+)?$/{s//\1/;p}' \
    | tail -n 1
}
