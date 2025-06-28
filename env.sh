#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/../..
base_dir=$PWD
env_dir=${env_dir:-.private/files}
echo Base dir: $base_dir
echo Env dir: $env_dir
case "${1:-}" in
save)
  mkdir -p $env_dir
  for f in $(find . -type f -name .env ! -path "./$env_dir/*"); do
    echo Saving $f...
    rsync -qR $f $env_dir/
  done
  ;;
restore)
  cd $env_dir
  for f in $(find . -type f -name .env); do
    echo Restoring $f...
    rsync -qR $f $base_dir/
  done
  ;;
*)
  cat <<EOF
Usage: $0 <save|restore>
EOF
  ;;
esac
