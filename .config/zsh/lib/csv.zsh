#!/bin/zsh

## NB: set IFS manually

z-csv-select() {
    local field value
    field="${1:?}" value="${2:?}"

    local line
    local -a ary
    while IFS='' read -rs line ; do
        [ -n "${line}" ] || continue

        ary=()
        read -rs -A ary <<< "${line}"
        [ "${ary[${field}]}" = "${value}" ] || continue

        printf '%s' "${line}"
        return 0
    done

    return 1
}

z-csv-field() {
    local field
    field="${1:?}"

    local -a ary
    read -rs -A ary

    printf '%s' "${ary[${field}]}"
}
