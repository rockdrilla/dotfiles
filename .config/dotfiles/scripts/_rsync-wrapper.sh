#!/bin/sh
set -ef

me="${0##*/}"
case "${me}" in
to | from ) ;;
* ) exit 1 ;;
esac

check-bin-pkg rsync ssh:openssh-client

h=$1 ; shift

rsync_aux=
for i ; do
	case "$i" in
	-*) rsync_aux="${rsync_aux}${rsync_aux:+' '}$i" ;;
	esac
done

for i ; do
	case "$i" in
	-* ) continue ;;
	*:* )
		k=${i#*:}
		case "$k" in
		*:* )
			env printf "%q: skipping bogus argument: %q\\n" "${me}" "$i" >&2
			continue
		;;
		esac
		i=${i%%:*}
	;;
	* ) k=$i ;;
	esac

	k="$h:$k"

	case "${me}" in
	to )   src=$i dst=$k ;;
	from ) src=$k dst=$i ;;
	esac

	rsync -vaxISc -e ssh ${rsync_aux} "${src}" "${dst}"
done
