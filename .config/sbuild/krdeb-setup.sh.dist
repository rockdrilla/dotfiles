set -ef ;

: "setup extra APT repositories from deb.krd.sh" ;
[ -n "${KRDEB_ENABLE}" ] || exit 0 ;

: "# upstream source: https://deb.krd.sh/krdeb.gpg.asc" ;
: "${KRDEB_KEYRING:=/etc/apt/keyrings/krdeb.gpg.asc}" ;

if [ -z "${KRDEB_URI}" ] ; then
    : "# plain http:// is ok" ;
    : "${KRDEB_ROOT_URI:=http://deb.krd.sh}" ;
    . /etc/os-release ;
    : "${KRDEB_URI:=${KRDEB_ROOT_URI}/${VERSION_CODENAME}}" ;
fi ;

KRDEB_SRC="/etc/apt/sources.list.d/krdeb.sources" ;

for i in ${KRDEB_ENABLE} ; do
    case "$i" in
    */* ) suite="${i%/*}" component="${i##*/}" ;;
    * )   suite="$i" component="main" ;;
    esac ;
    echo "Types: deb" ;
    echo "URIs: ${KRDEB_URI}" ;
    echo "Signed-By: ${KRDEB_KEYRING}" ;
    echo "Suites: ${suite}" ;
    echo "Components: ${component}" ;
    echo ;
done > "${KRDEB_SRC}" ;

[ -s "${KRDEB_SRC}" ] || exit 0 ;
head -v -n 1000000 "${KRDEB_SRC}"
