# 🔐 Sealed Secrets Setup (Dev Environment)

This repository manages the installation and usage of **Bitnami Sealed Secrets** for encrypting Kubernetes secrets that are safe to store in Git.

It uses:

- ✅ **Helmfile** to install the Sealed Secrets controller
- ⚙️ **Kustomize overlays** for environment-specific `SealedSecret` resources
- 🛡️ End-to-end GitOps-compatible secret lifecycle

---

## 📁 Directory Structure

```bash
sealed-secret/
├── README.md
├── overlays/
│ └── dev/
│ ├── kustomization.yaml # References sealed-secret.yaml and namespace.yaml
│ ├── namespace.yaml # Namespace where sealed secrets are stored
│ └── sealed-secret.yaml # Encrypted SealedSecret resource
└── setup/
├── helmfile.yaml # Helmfile for controller install
├── environments/
│ └── dev.yaml # Helmfile environment config
└── values/
└── dev-values.yaml # Values passed to the Sealed Secrets Helm chart
```


---

## ⚙️ Prerequisites

#### go to initial/ directory and install necessary tools and setup the kubernetes environment.

---

## 🚀 Installation Steps

### 1️⃣ Install Sealed Secrets Controller

```bash
cd setup
helmfile -e dev apply
```

This installs the Sealed Secrets controller into your cluster using the Bitnami Helm chart.

Helm values can be adjusted in:

- values/dev-values.yaml

- environments/dev.yaml

### 2️⃣ Create a Sealed Secret
Use the kubeseal CLI to encrypt a Kubernetes secret:

```bash
# 1. Create the original secret manifest
kubectl create secret generic my-secret \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml > my-secret.yaml

# 2. Encrypt the secret with public cert from the controller
kubeseal --controller-namespace sealed-secrets \
         --controller-name sealed-secrets-controller \
         --format yaml < my-secret.yaml > overlays/dev/sealed-secret.yaml

```
This generates a sealed secret that can only be decrypted by the Sealed Secrets controller in your cluster.



