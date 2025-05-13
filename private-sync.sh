#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/..
private_dir=../$(basename $PWD).private

case "${1:-}" in
to)
  shift
  for dir in "$@"; do
    echo Syncing ${dir%/} to $private_dir/ ...
    rsync -av ${dir%/} $private_dir/
    echo
  done
  ;;
from)
  shift
  for dir in "$@"; do
    echo Syncing ${dir%/} from $private_dir/ ...
    rsync -av $private_dir/${dir%/} .
    echo
  done
  ;;
*)
  cat <<EOF
Usage: $0 <to|from> dir1/ dir2/ ...
EOF
  ;;
esac
