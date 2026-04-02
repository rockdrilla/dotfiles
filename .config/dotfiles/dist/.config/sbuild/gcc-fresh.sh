set -ef ;
[ -n "${KRDEB_GCC_VER}" ] || exit 0 ;
apt-get update -yy ;
apt-get install -yy "cpp-${KRDEB_GCC_VER}" "g++-${KRDEB_GCC_VER}" "gcc-${KRDEB_GCC_VER}" "gnat-${KRDEB_GCC_VER}" "gfortran-${KRDEB_GCC_VER}" ;
dpkg-query --show --showformat='${source:Package}|${Package}\n' | awk -v "v=${KRDEB_GCC_VER}" -F '|' '$1!~"gcc" {next} $1=="gcc-defaults" {next} $1~v {next} $1~"^gcc" {print $2}' | xargs -r apt-get purge -yy ;
apt-get autoremove -yy ;
apt-get clean
