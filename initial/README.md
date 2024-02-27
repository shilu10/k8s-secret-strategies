# 🚀 ArgoCD Initial Bootstrap (Dev Environment)

This repository bootstraps a secure and extensible **ArgoCD GitOps setup** with:

- ✅ Declarative install using **Helmfile**
- 🧩 A required **custom `argocd-repo-server` Docker image**
- 🔐 Secret management support via **SOPS**
- ⚙️ Patching of ArgoCD's ConfigMap to enable plugins
- 📦 Environment-specific configs (e.g., `dev`)

---

## 📁 Directory Structure



```
├── Dockerfile.argoreposerver # Custom ArgoCD repo-server image (e.g., with SOPS plugin)
├── patch-argocd-cm.yaml # Patch for ArgoCD ConfigMap (plugins, timeout, etc.)
└── bootstrap/
├── helmfile.yaml # Helmfile to install ArgoCD
├── environments/
│ └── dev.yaml # Helmfile environment: dev
└── values/
└── dev-values.yaml # ArgoCD Helm chart values for dev
```


---

## ⚙️ Pre-Requirements

- Kubernetes Cluster
- [Helm](https://helm.sh/)
- [Helmfile](https://github.com/helmfile/helmfile)
- [SOPS](https://github.com/mozilla/sops)
- [Age](https://github.com/FiloSottile/age) or GPG for encryption
- [Vault CLI](https://developer.hashicorp.com/vault/docs/install)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#installation-from-source)
---

## 🚀 Installation Steps

## ⚠️ Required Customization

### ✅ 1. Build and Push the Custom ArgoCD Repo-Server Image

This image must include your tools — e.g., **SOPS**, **Age**, **kustomize**, etc.

#### Dockerfile.argoreposerver (Example)

```Dockerfile
FROM quay.io/argoproj/argocd:v2.11.0

USER root

RUN apt-get update && \
    apt-get install -y curl gnupg jq gettext && \
    curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 && \
    chmod +x sops-v3.8.1.linux.amd64 && \
    mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

USER argocd
```
```bash
docker build -t <your-registry>/argocd-repo-server:custom -f Dockerfile.argoreposerver .
docker push <your-registry>/argocd-repo-server:custom
```

✅ 2. Update dev-values.yaml to Use the Custom Image
Edit bootstrap/values/dev-values.yaml:

```yaml
repoServer:
  image:
    repository: <your-registry>/argocd-repo-server
    tag: custom

server:
    image:
     repository: <your-registry>/argocd-repo-server
     tag: custom
```


### ✅ 3 Install ArgoCD via Helmfile

```bash
cd bootstrap
helmfile -e dev apply
```
This installs the official ArgoCD Helm chart using custom values from:

- environments/dev.yaml

- values/dev-values.yaml


### ✅ 4 Patch ArgoCD ConfigMap
Customize ArgoCD with your plugins, repositories, or SOPS config:

```bash
kubectl patch configmap argocd-cm -n argocd --patch-file ../patch-argocd-cm.yaml
```

### 🔑 ArgoCD Admin Login
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward svc/argocd-server -n argocd 8080:443

```
