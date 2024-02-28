# 🔐 SOPS-Based Kubernetes Secret Management (Age & KMS)

This repository demonstrates how to manage encrypted Kubernetes secrets using [SOPS](https://github.com/mozilla/sops) and GitOps. It supports:

- ✅ Environment-specific overlays (dev and prod)
- 🔑 Encryption via Age keys
- 🛡️ Encryption via KMS (AWS, GCP, Azure, etc.)
- ⚙️ Kustomize native secret generation via `generators/`
- 🧩 Integration with ArgoCD using KSOPS plugin

---

## 📁 Project Structure

```bash
├── README.md
├── overlays/
│ ├── dev/
│ │ ├── namespace.yaml
│ │ ├── generators/secret-generator.yaml
│ │ ├── secret.dev.enc.yaml # Encrypted with SOPS
│ │ └── patches/
│ │ ├── replica_count.yaml
│ │ └── rolling_update.yaml
│ └── prod/
│ ├── namespace.yaml
│ ├── generators/secret-generator.yaml
│ ├── secret.prod.enc.yaml
│ └── patches/
│ ├── replica_count.yaml
│ └── rolling_update.yaml
└── setup/
├── age-key/
│ ├── create-secret.sh # Stores age key in K8s for ArgoCD
│ ├── argo-cd-cm-patch.yaml # Patches ArgoCD config to enable ksops plugin
│ └── argo-cd-repo-server-patch.yaml # Mounts age key into repo-server
├── kms/
│ ├── argo-cd-cm-patch.yaml
│ └── argo-cd-repo-server-ksops-patch.yaml
└── extras/
├── Dockerfile.ksops # Custom repo-server image (if needed)
└── values.yaml # Extra Helm values (if using helmfile)
```


---

## 🔐 What Is SOPS?

[SOPS](https://github.com/mozilla/sops) is a tool that encrypts secrets inside structured files like YAML or JSON using:

- Age key (simple, file-based public/private key)
- KMS (e.g., AWS KMS, GCP KMS, Azure Key Vault)
- PGP

---

## 🛠️ Prerequisites

### go to initial/ and install necessary tools and bootstrap the cluster and also it is necessary to do below steps.

---

## 🔄 Switching Between Age and KMS
🧭 Your encryption setup must use one of the following directories depending on your secret backend:
### ✅ If you're using Age-based encryption:
Use files under:

```bash
setup/age-key/
├── argo-cd-cm-patch.yaml             # Enables KSOPS plugin in ArgoCD ConfigMap
├── argo-cd-repo-server-patch.yaml   # Mounts the Age private key into repo-server
├── create-secret.sh                 # Converts `age.key` to K8s Secret for repo-server

```
Also:

Update .sops.yaml to reference your Age public key

Store your age.key securely and use create-secret.sh to inject it into ArgoCD

### ✅ If you're using KMS-based encryption:
Use files under:
```bash
setup/kms/
├── argo-cd-cm-patch.yaml                 # Enables KSOPS plugin
├── argo-cd-repo-server-ksops-patch.yaml # Adds env/volumes for cloud SDK or IAM auth
````

Also:

Update .sops.yaml with your KMS ARN (e.g., AWS, GCP, Azure)

Ensure ArgoCD's repo-server has the correct IAM role or access to decrypt

## 🚀 Usage Overview

### 1️⃣ Encrypt Secrets with SOPS

```bash
sops -e secret.yaml > secret.dev.enc.yaml
```
The secret should match what’s expected in the generator file (name, keys, etc.)

and put it into /overlays/dev/ and also do above step for prod and put the secret.prod.enc.yaml into /overlays/prod
