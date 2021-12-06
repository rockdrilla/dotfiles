#!/bin/zsh

## alternatives list is pipe-separated list of commands/binaries

## find (first) candidate in alternatives
## $1 - alternatives list
## $2 - arguments to test command (USE WITH CAUTION!)
z-alt-find() {
    local i c r t
    local -a v a

    v=( ${(@s:|:)1} )
    [ ${#v} = 0 ] && v=( "$1" )
    for i ( $v ) ; do
        a=( ${(@s: :)i} )

        c=$(which "${a[1]}")
        [ -z "$c" ] && continue
        a[1]="$c"

    #   r=$(readlink -f "$c" 2>/dev/null)
    #   [ -z "$r" ] && continue
    #   a[1]="$r"

        if [ -n "$2" ] ; then
            t="$a $2"
            command ${(@s: :)t} </dev/null &>/dev/null || continue
        fi

        echo "${a[@]}"
        return 0
    done

    return 127
}

## set function alias for alternative (one-time static resolve)
## $1 - function name
## $2 - alternatives list
## $3 - command wrapper
## $4 - function prologue
## $5 - function epilogue
z-alt-set-static() {
    local n t a r
    local -a s
    n="$1" ; t=''
    if [[ "$n" =~ '\|' ]] ; then
        t=${n:${MBEGIN}} ; n=${n:0:${MBEGIN}-1}
    fi
    a=$(z-alt-find "$2" "$t")
    if [ -n "$a" ] ; then
        r=0
        [ -n "$4" ] && s+=( "$4 ;" )
        s+=( "${3:-command}" )
        s+=( "$a \"\$@\" || return 127" )
        [ -n "$5" ] && s+=( "; $5" )
    else
        r=127
        s+=( 'return 127' )
    fi
    eval "$n () { ${s[@]} ; } ; typeset -g $n"
    return $r
}

## set function alias for alternative (dynamic resolve)
## $1 - function name
## $2 - alternatives list
## $3 - command wrapper
## $4 - function prologue
## $5 - function epilogue
z-alt-set-dynamic() {
    local n t
    local -a s
    n="$1" ; t=''
    if [[ "$n" =~ '\|' ]] ; then
        t=${n:${MBEGIN}} ; n=${n:0:${MBEGIN}-1}
    fi
    [ -n "$4" ] && s+=( "$4 ;" )
    s+=( 'local a=$(z-alt-find' "${(qq)2}" "${t:+' $t'} ) ;" )
    s+=( "${3:-command}" )
    s+=( '${(@s: :)a} "$@" || return 127' )
    [ -n "$5" ] && s+=( "; $5" )
    eval "$n () { ${s[@]} ; } ; typeset -g $n"
}
