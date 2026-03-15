#!/bin/zsh

typeset -g -A ZSHU

__z_diff_test_opt() {
    diff "$@" "${ZSHU[d_dotfiles]}/gitignore" "${ZSHU[d_dotfiles]}/gitignore" >/dev/null 2>&1
}

ZSHU[diff_color]=0
if __z_diff_test_opt --color ; then
    ZSHU[diff_color]=1
fi

if [ "${ZSHU[diff_color]}" = 1 ] ; then
    z-diff() { diff -Naru --color "$@" ; }
else
    z-diff() { diff -Naru "$@" ; }
fi
