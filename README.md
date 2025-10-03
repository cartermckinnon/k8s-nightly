# Nightly builds of Kubernetes

This project provides nightly builds of Kubernetes, sourced from the upstream project's CI system.

---

## Usage

Container images are hosted on GitHub Container Registry (`ghcr.io`), but you won't see them in the repository's package list.
This requires adding a label to the images, changing the digest in the process.

The container images are under `ghcr.io/cartermckinnon/k8s-nightly`, for example:
```
docker pull ghcr.io/cartermckinnon/k8s-nightly/kube-apiserver
```
