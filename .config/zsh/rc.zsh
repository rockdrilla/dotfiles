#!/bin/zsh

typeset -a zshu_modules
## DEBUG module load order
# typeset -a zshu_m0 zshu_m1
zshu_modules=(
    clone
    langinfo
    parameter
    sched
    termcap
    terminfo
    watch
    zpty

    zle
    zleparameter
    deltochar
    complete
    complist
    computil
    zutil
    compctl
)
for i ( ${zshu_modules} ) ; do
    i="zsh/$i"
    ## DEBUG module load order
    # zshu_m0=( $(zmodload) )
    # if ((${zshu_m0[(Ie)${i}]})); then
    #     echo "# already loaded: $i" >&2
    #     continue
    # fi

    zmodload "$i"

    ## DEBUG module load order
    # zshu_m1=( $(zmodload) )
    # for k ( ${zshu_m1} ) ; do
    #     if [ "$k" = "$i" ] ; then continue ; fi
    #     if ((${zshu_m0[(Ie)${k}]})); then
    #         continue
    #     fi
    #     echo "# new module loaded (with $i): $k" >&2
    # done
done
unset i zshu_modules
## DEBUG module load order
# unset zshu_m0 zshu_m1

autoload -Uz +X colors && colors
