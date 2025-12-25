#!/bin/zsh

typeset -g -A ZSHU_TERM
typeset -g -aU ZSHU_TERM_MISSING

z-ti-test() {
    local r i

    r=0
    for i ; do
        [ -z "$i" ] && continue
        if ! (( ${+terminfo[$i]} )) ; then
            ZSHU_TERM_MISSING+=( "$1" )
            r=1
        fi
    done

    return $r
}

case "${TERM}" in
xterm* | putty* | rxvt* | konsole* | mlterm* | alacritty* | foot* | contour* )
    ZSHU_TERM[has_title_tab]=1
    ZSHU_TERM[has_title_wnd]=1
    ZSHU_TERM[want_cwd]=1

    ZSHU_TERM[title_tab]=term
    ZSHU_TERM[title_wnd]=term
;;
st* | wezterm* )
    ZSHU_TERM[has_title_tab]=1
    ZSHU_TERM[has_title_wnd]=1

    ZSHU_TERM[title_tab]=term
    ZSHU_TERM[title_wnd]=term
;;
cygwin | ansi )
    ZSHU_TERM[has_title_tab]=1
    ZSHU_TERM[has_title_wnd]=1

    ZSHU_TERM[title_tab]=term
    ZSHU_TERM[title_wnd]=term
;;
screen* | tmux* )
    ZSHU_TERM[has_title_tab]=1
    ZSHU_TERM[want_cwd]=1

    ZSHU_TERM[title_tab]=mux
;;
* )
    if z-ti-test fsl tsl ; then
        ZSHU_TERM[has_title_tab]=1
        ZSHU_TERM[want_cwd]=1

        ZSHU_TERM[title_tab]=terminfo
    fi
;;
esac

z-term-title-tab() {
    # [ "${ZSHU_TERM[has_title_tab]}" = 1 ] || return 1

    case "${ZSHU_TERM[title_tab]:-}" in
    term )
        print -Pn "\e]1;${1:q}\a"
    ;;
    mux )
        ## screen/tmux: hardstatus
        print -Pn "\ek${1:q}\e\\"
    ;;
    terminfo )
        echoti tsl
        print -Pn "$1"
        echoti fsl
    ;;
    esac
}

z-term-title-window() {
    # [ "${ZSHU_TERM[has_title_wnd]}" = 1 ] || return 1

    case "${ZSHU_TERM[title_wnd]:-}" in
    term )
        print -Pn "\e]2;${1:q}\a"
    ;;
    esac
}

z-term-title() {
    ## if $2 is unset use $1 as default
    ## if it is set and empty, leave it as is
    : ${2=$1}

    z-term-title-tab "$1"
    z-term-title-window "$2"
}

z-term-cwd() {
    [ "${ZSHU_TERM[want_cwd]}" = 1 ] || return 1

    local host path
    host=${HOST:-localhost}
    path=${PWD}

    ## Konsole doesn't want ${host}
    while : ; do
        [ -n "${KONSOLE_DBUS_SERVICE}" ] || break
        [ -n "${KONSOLE_DBUS_SESSION}" ] || break
        [ -n "${KONSOLE_DBUS_WINDOW}" ] || break
        [ -n "${KONSOLE_PROFILE_NAME}" ] || break
        host=
    break;done

    printf "\e]7;file://%s%s\e\\" "${host}" "${path}"
}

if autoload -Uz add-zsh-hook ; then

ZSHU[term_title]=1
z-term-title-enable()  { ZSHU[term_title]=1 ; }
z-term-title-disable() { ZSHU[term_title]=0 ; }

ZSHU[title_tab]='%15<..<%~%<<'
ZSHU[title_wnd]='%n@%m:%~'
__z_term_title_precmd() {
    [ "${ZSHU[term_title]}" = 1 ] || return
    z-term-title "${ZSHU[title_tab]}" "${ZSHU[title_wnd]}"
}
add-zsh-hook precmd  __z_term_title_precmd

ZSHU[term_cwd]=1
z-term-cwd-enable()  { ZSHU[term_cwd]=1 ; }
z-term-cwd-disable() { ZSHU[term_cwd]=0 ; }

__z_term_cwd_precmd() {
    [ "${ZSHU[term_cwd]}" = 1 ] || return
    z-term-cwd
}
## "chpwd" doesn't always hook pwd changes
add-zsh-hook precmd  __z_term_cwd_precmd

else

echo "current working directory and tab/window title handling is disabled due to missing hook support" >&2

z-term-title-enable()  { __z_unsupported ; }
z-term-title-disable() { __z_unsupported ; }

z-term-cwd-enable()  { __z_unsupported ; }
z-term-cwd-disable() { __z_unsupported ; }

fi
