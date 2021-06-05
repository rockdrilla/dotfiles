#!/bin/zsh

typeset -gA ZSHU
ZSHU[title_tab]='%15<..<%~%<<'
ZSHU[title_window]='%n@%m:%~'

z-title-tab() {
    emulate -L zsh

    case "${TERM}" in
    cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|st*)
        print -Pn "\e]1;${1:q}\a"
    ;;
    screen*|tmux*)
        ## hardstatus
        print -Pn "\ek${1:q}\e\\"
    ;;
    *)
        z-ti-test fsl tsl || break

        echoti tsl
        print -Pn "$1"
        echoti fsl
    ;;
    esac
}

z-title-window() {
    emulate -L zsh

    case "${TERM}" in
    cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|st*)
        print -Pn "\e]2;${1:q}\a"
    ;;
    esac
}

z-title() {
    emulate -L zsh

    ## if $2 is unset use $1 as default
    ## if it is set and empty, leave it as is
    : ${2=$1}

    z-title-tab "$1"
    z-title-window "$2"
}

if autoload -Uz add-zsh-hook ; then

__z_title_precmd() {
    z-title "${ZSHU[title_tab]}" "${ZSHU[title_window]}"
}

add-zsh-hook precmd  __z_title_precmd

else
    echo "tab/window title handling is disabled due to missing hook support" 1>&2
fi
