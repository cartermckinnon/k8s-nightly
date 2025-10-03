#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo >&2 "usage: $0 GITHUB_REPOSITORY"
  exit 1
fi

GITHUB_REPOSITORY="${1}"
TARGET_REGISTRY="ghcr.io/${GITHUB_REPOSITORY}"

IMAGES=(
  "kube-apiserver"
  "kube-controller-manager"
  "kube-scheduler"
)

IMAGE_TAG=$(curl --silent "https://storage.googleapis.com/k8s-release-dev/ci/k8s-master.txt")

# v1.35.0-alpha.0.1050+aa38aeaca28899 -> v1.35.0-alpha.0.1050_aa38aeaca28899
IMAGE_TAG="${IMAGE_TAG//+/_}"

echo "Capturing image tag: ${IMAGE_TAG}"

BUILD_DIR="${PWD}/.build/"
mkdir -p "${BUILD_DIR}"
export GOBIN="${BUILD_DIR}"
export PATH=$GOBIN:$PATH

go install github.com/google/go-containerregistry/cmd/crane@latest

FAILED_IMAGES=()
for IMAGE in ${IMAGES[@]}; do
  IMAGE_TARBALL="${BUILD_DIR}/${IMAGE}.tar"
  TARGET_IMAGE="${TARGET_REGISTRY}/${IMAGE}:latest"
  if ! crane pull "gcr.io/k8s-staging-ci-images/${IMAGE}:${IMAGE_TAG}" "${IMAGE_TARBALL}"; then
    echo "Failed to pull image: ${IMAGE}"
    FAILED_IMAGES+=("${IMAGE}")
  elif ! crane push "${IMAGE_TARBALL}" "${TARGET_IMAGE}"; then
    echo "Failed to push image: ${IMAGE}"
    FAILED_IMAGES+=("${IMAGE}")
  elif ! crane mutate "${TARGET_IMAGE}" --label org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}/"; then
    echo "Failed to label image: ${IMAGE}"
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
