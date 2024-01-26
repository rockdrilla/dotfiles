#!/bin/zsh

z-ts-to-human() {
    local t s n d h m f x

    t=$1
    t=$[ float(t) ]
    s=$[ int(t) ]
    n=$[ int((t - s) * (10**9)) ]
    t=$s

    d=0 h=0 m=0
    if [ $t -ge 86400 ] ; then
        d=$[ t / 86400 ]
        t=$[ t % 86400 ]
    fi
    if [ $t -ge 3600 ] ; then
        h=$[ t / 3600 ]
        t=$[ t % 3600 ]
    fi
    if [ $t -ge 60 ] ; then
        m=$[ t / 60 ]
        t=$[ t % 60 ]
    fi

    ## strftime does desired rounding for $n/(10**9) internally
    f=$(strftime '%s.%6.' $t $n)
    ## keep math in sync with format above
    x=3
    case "$2" in
    0 )     x=7 ;;
    [1-6] ) x=$[ 6 - $2 ] ;;
    esac
    [ $x -gt 0 ] && f="${f:0:-$x}s"

    [ $s -ge 60    ] && f="${m}m:$f"
    [ $s -ge 3600  ] && f="${h}h:$f"
    [ $s -ge 86400 ] && f="${d}d:$f"

    echo "$f"
}
