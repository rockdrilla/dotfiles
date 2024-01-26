#!/bin/zsh

case "${ZSHU[os_type]}" in
linux-gnu ) alias tl='telnet -K ' ;;
*bsd* )     alias tl='telnet -K -N -y ' ;;
esac
