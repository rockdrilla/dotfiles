#!/bin/zsh

fc() { builtin fc -i "$@" ; }

# alias history='z-history '
history() { builtin fc -il "$@" ; }
