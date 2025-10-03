# Nightly builds of Kubernetes

This project provides nightly builds of Kubernetes, sourced from the upstream project's CI system.

> [!WARNING]
> Don't use this in production.

---

## Usage

Container images are hosted on GitHub Container Registry (`ghcr.io`), for example:
```
docker pull ghcr.io/cartermckinnon/k8s-nightly/kube-apiserver
```
