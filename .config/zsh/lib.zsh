#!/bin/zsh

disable which
which() { builtin whence -p "$@"; }
which-command() { builtin whence -p "$@"; }
zsh-which() { builtin whence -c "$@"; }
