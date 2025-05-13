#!/usr/bin/env bash
#
# This script is used to save and restore docker images
# to skipping the download of some images.
#
# Author: Paulo Jeronimo <paulojeronimo@gmail.com>
#
set -euo pipefail
cd $(dirname $0)/..

DOCKER_IMAGES_DIR=${DOCKER_IMAGES_DIR:-.docker-images}

case "${1:-}" in
save)
  mkdir -p "$DOCKER_IMAGES_DIR"
  docker images --format "{{.Repository}} {{.Tag}}" | while read -r repo tag; do
    [ -z "$repo" ] || [ -z "$tag" ] && continue

    filename="${repo//\//_}_${tag//:/_}.tar"
    filepath="$DOCKER_IMAGES_DIR/$filename"

    echo "Saving docker image $repo:$tag to $filepath"
    docker save -o "$filepath" "$repo:$tag"
  done
  ;;
restore)
  if [ ! -d "$DOCKER_IMAGES_DIR" ]; then
    echo "Error: Docker images directory '$DOCKER_IMAGES_DIR' not found"
    exit 1
  fi

  for filepath in "$DOCKER_IMAGES_DIR"/*.tar; do
    [ -f "$filepath" ] || continue
    echo "Loading docker image from $filepath"
    docker load -i "$filepath"
  done
  ;;
remove)
  echo "WARNING: This will remove ALL Docker images from your system."
  echo "Images to be removed:"
  docker images
  read -p "Are you sure you want to continue? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing all Docker images..."
    docker images -q | xargs -r docker rmi -f
  else
    echo "Operation cancelled."
    exit 0
  fi
  ;;
*)
  cat <<EOF
Usage: $0 <save|restore|remove>
EOF
  ;;
esac
