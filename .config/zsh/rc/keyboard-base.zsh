#!/bin/zsh

typeset -g -A ZSHU_TI_KEYS
typeset -g -A ZSHU_FB_KEYS

if z-ti-test smkx rmkx ; then
    zle-line-init()   { echoti smkx ; }
    zle-line-finish() { echoti rmkx ; }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

## key [sequence] via terminfo
z-kseq-ti() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return

    z-ti-test "$2" && ZSHU_TI_KEYS[${terminfo[$2]}]=$1
}

## key [sequence] via fallback
z-kseq-fb() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return

    ZSHU_FB_KEYS[$2]=$1
}

z-kseq-ti Backspace  kbs

z-kseq-ti Home       khome
z-kseq-ti End        kend
z-kseq-ti Insert     kich1
z-kseq-ti Delete     kdch1

z-kseq-ti Up         kcuu1
z-kseq-ti Down       kcud1
z-kseq-ti Left       kcub1
z-kseq-ti Right      kcuf1

z-kseq-ti PageUp     kpp
z-kseq-ti PageDown   knp

z-kseq-ti Shift-Tab  kcbt

z-kseq-fb Backspace        '^?'
z-kseq-fb Home             '^[[H'
z-kseq-fb End              '^[[F'
z-kseq-fb Insert           '^[[2~'
z-kseq-fb Delete           '^[[3~'
z-kseq-fb Delete #         '^[3;5~'

z-kseq-fb Up               '^[[A'
z-kseq-fb Down             '^[[B'
z-kseq-fb Left             '^[[D'
z-kseq-fb Right            '^[[C'

z-kseq-fb PageUp           '^[[5~'
z-kseq-fb PageDown         '^[[6~'

z-kseq-fb Ctrl-Delete      '^[[3;5~'
z-kseq-fb Ctrl-RightArrow  '^[[1;5C'
z-kseq-fb Ctrl-LeftArrow   '^[[1;5D'

z-kseq-fb Esc-w            '\ew'

z-bind () {
    local -a maps
    local -Ua keys
    local widget i k

    while [ "$1" != "--" ] ; do
        maps+=( "$1" )
        shift
    done
    shift

    widget="$2"

    keys+=( ${(k)ZSHU_TI_KEYS[(r)$1]} )
    keys+=( ${(k)ZSHU_FB_KEYS[(r)$1]} )

    [ ${#keys} -eq 0 ] && return 1

    case "${widget}" in
    /* )
        widget=${widget:1}
        autoload -RUz "${widget}"
        zle -N "${widget}"
    ;;
    esac

    for i in "${maps[@]}" ; do
        for k in "${keys[@]}" ; do
            bindkey -M "$i" "$k" "${widget}"
        done
    done
}

z-bind emacs             -- Backspace        backward-delete-char
z-bind       viins       -- Backspace        vi-backward-delete-char
z-bind             vicmd -- Backspace        vi-backward-char
z-bind emacs             -- Home             beginning-of-line
z-bind       viins vicmd -- Home             vi-beginning-of-line
z-bind emacs             -- End              end-of-line
z-bind       viins vicmd -- End              vi-end-of-line
z-bind emacs viins       -- Insert           overwrite-mode
z-bind             vicmd -- Insert           vi-insert
z-bind emacs             -- Delete           delete-char
z-bind       viins vicmd -- Delete           vi-delete-char
z-bind emacs viins vicmd -- Up              /up-line-or-beginning-search
z-bind emacs viins vicmd -- Down            /down-line-or-beginning-search
z-bind emacs             -- Left             backward-char
z-bind       viins vicmd -- Left             vi-backward-char
z-bind emacs             -- Right            forward-char
z-bind       viins vicmd -- Right            vi-forward-char
z-bind emacs viins vicmd -- PageUp           up-line-or-history
z-bind emacs viins vicmd -- PageDown         down-line-or-history

z-bind emacs viins vicmd -- Shift-Tab        reverse-menu-complete

z-bind emacs viins vicmd -- Ctrl-Delete      kill-word
z-bind emacs             -- Ctrl-RightArrow  forward-word
z-bind       viins vicmd -- Ctrl-RightArrow  vi-forward-word
z-bind emacs             -- Ctrl-LeftArrow   backward-word
z-bind       viins vicmd -- Ctrl-LeftArrow   vi-backward-word

z-bind emacs viins vicmd -- Esc-w            kill-region

## use emacs key bindings
bindkey -e
