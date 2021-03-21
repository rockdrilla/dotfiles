#!/bin/zsh

## kinda unlimited history
HISTSIZE=10000000
SAVEHIST=10000000

ZSHU[f_hist]="${ZSHU[d_var]}/history"
[ -f "${ZSHU[f_hist]}" ] || touch "${ZSHU[f_hist]}"

HISTFILE="${ZSHU[f_hist]}"
