#!/bin/zsh

__z_compdump_verify

## :completion:<function-name>:<completer>:<command>:<argument>:<tag>

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "${ZSHU[d_compcache]}"

bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' special-dirs true

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*:*:*:users' ignored-patterns adm amanda apache at avahi avahi-autoipd backup beaglidx bin bind cacti canna clamav colord daemon dbus distcache dnsmasq dovecot fax ftp games gdm gkrellmd gnats gopher hacluster haldaemon halt hplip hsqldb ident irc junkbust kdm ldap list lp mail mailman mailnull man messagebus mldonkey mysql nagios named netdump news nfsnobody nginx nobody nscd ntp ntpsec nut nx obsrun openvpn operator pcap polkitd postfix postgres privoxy proxy pulse pvm quagga radvd redsocks rpc rpcuser rpm rtkit saned sbuild sbws scard sddm shutdown speech-dispatcher squid sshd statd svn sync sys tcpdump tftp tss usbmux uucp uuidd vcsa wwwrun www-data x2gouser xfs '_*' 'systemd-*' 'debian-*' 'Debian-*'
zstyle '*' single-ignored show

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

if autoload -Uz +X bashcompinit ; then
    bashcompinit && ZSHU[compdump_bash]=1
fi

autoload -Uz +X compinit && \
compinit -i -C -d "${ZSHU[f_compdump]}"

function {
    local i
    for i ( ${ZSHU[d_conf]}/completion/*.zsh(N.r) ) ; do
        source "$i"
    done
    for i ( ${ZSHU[d_conf]}/local/completion/*.zsh(N.r) ) ; do
        source "$i"
    done
}

__z_compdump_finalize
