#!/bin/bash
# This bash script allows a user to manually build/tag/push docker images in $ROOT/images/ to a given container registry (ACR or GCR).
# It assumes that docker is installed on the running machine and that the caller has already authenticated to the target registry.
# It also assumes the existence of a yaml file containing the correct tags for each image.

DEFAULT_CR_PREFIX="azcpg001acr.azurecr.io/cpg-common/images"
DEFAULT_TAG_LIST="../images.toml"

print_help() {
      echo "manual_image_deploy.sh -i IMAGE [-r REGISTRY] [-t TAG]"
      echo 
      echo "Options:"
      echo "  -i IMAGE"
      echo "      The image to build/tag/push, "
      echo "  -r REGISTRY_PREFIX"
      echo "      The container registry prefix to push the image to, defaults to ${DEFAULT_CR_PREFIX}"
      echo "  -t TAG"
      echo "      The tag to apply to the image, by default will find the corresponding tag in ${DEFAULT_TAG_LIST}"
}

main() {
  # Determine options
  prefix=$DEFAULT_CR_PREFIX
  readonly GETOPTS_STR="i:r:t:"
  while getopts "${GETOPTS_STR}" option; do
    case "${option}" in
      i) image="${OPTARG}";;
      r) prefix="${OPTARG}";;
      t) tag="${OPTARG}";;
      ?) echo "Invalid command flag: -${OPTARG}"; print_help; exit 2;;
    esac
  done

  # Determine the correct tag
  if [ -z "$tag" ]; then
    tag=$(grep "${image} =" images.toml | sed -n "s/${image} = '\([0-9a-zA-Z.]\+\)'/\1/p");
  fi

  if [ -z "$tag" ]; then
    echo "ERROR: no tag provided nor found in ${DEFAULT_TAG_LIST}, exiting."
    exit 2
  fi

  # Build image
  docker build --tag "${prefix}/${image}:${tag}" images/$image

  # Push image
  docker push "${prefix}/${image}:${tag}"
}

# Run main
main "$@"


