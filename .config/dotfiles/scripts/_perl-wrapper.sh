#!/bin/sh
set -ef

e=perl ; d=
case "${0##*/}" in
d* )
	e=debugperl

	check-bin-pkg "$e:perl-debug"

	case "$1" in
	-* )
		d=$1 ; shift
	;;
	esac
;;
esac

export PERL_HASH_SEED=0 PERL_PERTURB_KEYS=0

$e $d -T -c "$@" || echo
exec $e $d -T "$@"
