set -ef ;

: "setup extra APT repositories from deb.krd.sh" ;
[ -n "${KRDEB_ENABLE}" ] || exit 0 ;

: "# upstream source: https://deb.krd.sh/krdeb.gpg.asc" ;
: "${KRDEB_KEYRING:=/etc/apt/keyrings/krdeb.gpg.asc}" ;

. /etc/os-release ;

if [ -z "${KRDEB_ROOT_URI}" ] ; then
    : "# plain http:// is ok" ;
    : "${KRDEB_ROOT_URI:=http://deb.krd.sh}" ;
fi ;

if [ -z "${KRDEB_SRC}" ] ; then
    KRDEB_SRC="/etc/apt/sources.list.d/krdeb.sources" ;
fi ;

for i in ${KRDEB_ENABLE} ; do
    codename=${VERSION_CODENAME} ;
    case "$i" in
    *:* ) codename="${i%%:*}" ; i="${i#*:}" ;;
    esac ;

    component="main" ;
    case "$i" in
    */* ) suite="${i%/*}" component="${i##*/}" ;;
    * )   suite="$i" ;;
    esac ;

    echo "Types: deb" ;
    echo "URIs: ${KRDEB_ROOT_URI}/${codename}" ;
    echo "Signed-By: ${KRDEB_KEYRING}" ;
    echo "Suites: ${suite}" ;
    echo "Components: ${component}" ;
    echo ;
done > "${KRDEB_SRC}" ;

[ -s "${KRDEB_SRC}" ] || exit 0 ;
head -v -n 1000000 "${KRDEB_SRC}"
