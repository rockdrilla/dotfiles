#!/bin/sh
set +e ; set -f

find "$@" -follow -type f -print0 \
| xargs -0 -r -n 128 stat -L --printf='%d:%i|%n\0' \
| sort -z -u -t '|' -k1,1 \
| cut -z -d '|' -f 2 \
| tr '\0' '\n'
