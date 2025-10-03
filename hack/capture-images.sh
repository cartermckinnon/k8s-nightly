#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo >&2 "usage: $0 TARGET_REGISTRY"
  exit 1
fi

TARGET_REGISTRY="${1}"

IMAGES=(
  "kube-apiserver"
  "kube-controller-manager"
  "kube-scheduler"
)

IMAGE_TAG=$(curl "https://storage.googleapis.com/k8s-release-dev/ci/k8s-master.txt")

# v1.35.0-alpha.0.1050+aa38aeaca28899 -> v1.35.0-alpha.0.1050_aa38aeaca28899
IMAGE_TAG="${IMAGE_TAG//+/_}"

go install github.com/google/go-containerregistry/cmd/crane@latest

FAILED_IMAGES=()
for IMAGE in ${IMAGES[@]}; do
  if ! crane pull "gcr.io/k8s-staging-ci-images/${IMAGE}:${IMAGE_TAG}" "${IMAGE}.tar"; then
    echo "Failed to pull image: ${IMAGE}"
    FAILED_IMAGES+=("${IMAGE}")
  elif ! crane push "${IMAGE}.tar" "${TARGET_REGISTRY}/${IMAGE}:latest"; then
    echo "Failed to push image: ${IMAGE}"
    FAILED_IMAGES+=("${IMAGE}")
  else
    echo "Captured image: ${IMAGE}"
  fi
done

if [[ ${#FAILED_IMAGES[@]} -gt 0 ]]; then
  echo "Failed to capture some images: ${FAILED_IMAGES[@]}"
  exit 1
fi

echo "Captured images: ${IMAGES[@]}"
