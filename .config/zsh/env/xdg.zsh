#!/bin/zsh

: ${XDG_CONFIG_HOME:=${HOME}/.config}
: ${XDG_CACHE_HOME:=${HOME}/.cache}
: ${XDG_DATA_HOME:=${HOME}/.local/share}
: ${XDG_RUNTIME_DIR:=${TMPDIR}}
: ${XDG_DATA_DIRS:=/usr/local/share:/usr/share}
: ${XDG_CONFIG_DIRS:=/etc/xdg}

typeset -x -m 'XDG*'

typeset -x -T XDG_DATA_DIRS    xdg_data_dirs
typeset -x -T XDG_CONFIG_DIRS  xdg_config_dirs
