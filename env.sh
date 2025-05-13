#!/usr/bin/env bash
#
# This script saves and restores .env files available in the directory
# at the same hierarchical level and with the same name as this project
# but with the .private extension.
#
# Author: Paulo Jeronimo <paulojeronimo@gmail.com>
#
set -eou pipefail
cd $(dirname $0)/..
base_dir=$PWD
env_dir=../$(basename $base_dir).private
case "${1:-}" in
save)
  echo Saving .env files to $env_dir...
  mkdir -p $env_dir
  for f in $(find . -type f -name .env); do
    rsync -qR $f $env_dir/
  done
  ;;
restore)
  echo Restoring .env files from $env_dir...
  cd $env_dir
  for f in $(find . -type f -name .env); do
    rsync -qR $f $base_dir/
  done
  ;;
*)
  cat <<EOF
Usage: $0 <save|restore>
EOF
  ;;
esac

