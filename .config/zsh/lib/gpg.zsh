#!/bin/zsh

z-gpgconf-comp-avail() {
    (( ${+commands[gpgconf]} )) || return 127

    local comp
    comp="${1:?}"

    local csv
    csv=$(command gpgconf --list-components | IFS=':' z-csv-select 1 "${comp}")
    [ -n "${csv}" ]
}

z-gpgconf-comp-opt-avail() {
    (( ${+commands[gpgconf]} )) || return 127

    local comp opt
    comp="${1:?}" opt="${2:?}"
    
    z-gpgconf-comp-avail "${comp}" || return $?

    local csv
    csv=$(command gpgconf --list-options "${comp}" | IFS=':' z-csv-select 1 "${opt}")
    [ -n "${csv}" ]
}

## merely that command:
##   gpgconf --list-options "$1" | awk -F: "/^$2:/{ print \$10 }"
z-gpgconf-getopt() {
    (( ${+commands[gpgconf]} )) || return 127

    local comp opt
    comp="${1:?}" opt="${2:?}"

    ## not really necessary here
    # z-gpgconf-comp-opt-avail "${comp}" "${opt}" || return $?

    local csv
    csv=$(command gpgconf --list-options "${comp}" | IFS=':' z-csv-select 1 "${opt}")
    [ -n "${csv}" ] || return 1

    local v
    v=$(IFS=':' z-csv-field 10 <<< "${csv}")
    printf '%s' "$v"
}
