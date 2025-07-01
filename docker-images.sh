#!/usr/bin/env bash
set -euo pipefail
cd $(dirname $0)/../..
base_dir=$PWD
docker_images_dir=${docker_images_dir:-.private/docker-images}
echo Base dir: $base_dir
echo Docker images dir: $docker_images_dir
case "${1:-}" in
save)
  mkdir -p "$docker_images_dir"
  docker images --format "{{.Repository}} {{.Tag}}" | while read -r repo tag; do
    [ -z "$repo" ] || [ -z "$tag" ] && continue

    filename="${repo//\//_}_${tag//:/_}.tar"
    filepath="$docker_images_dir/$filename"

    echo "Saving docker image $repo:$tag to ${filepath#$docker_images_dir/}"
    docker save -o "$filepath" "$repo:$tag"
  done
  ;;
restore)
  if [ ! -d "$docker_images_dir" ]; then
    echo "WARNING: Docker images directory '$docker_images_dir' not found. Nothihng to do."
    exit 0
  fi

  for filepath in "$docker_images_dir"/*.tar; do
    [ -f "$filepath" ] || continue
    echo "Loading docker image from ${filepath#$docker_images_dir/}"
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
