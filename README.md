# 🔐 Kubernetes Secret Management (GitOps-Ready)

This monorepo provides a **comprehensive GitOps-based solution** for managing Kubernetes secrets using:

- ✅ **Sealed Secrets**
- ✅ **External Secrets Operator (ESO)** + Vault
- ✅ **Secrets Store CSI Driver** + Vault
- ✅ **SOPS with KSOPS Plugin** (via Age or KMS)

All modules are ArgoCD-compatible and environment-aware (`dev`, `prod`), with secure secret lifecycle practices.

---

## 🚀 Tools Used

| Tool | Purpose |
|------|---------|
| [ArgoCD](https://argo-cd.readthedocs.io/) | GitOps controller for syncing manifests |
| [Helmfile](https://github.com/helmfile/helmfile) | Declarative Helm chart deployments |
| [SOPS](https://github.com/mozilla/sops) | Securely encrypt secrets in Git |
| [KSOPS](https://github.com/viaduct-ai/kustomize-sops) | Kustomize + SOPS integration |
| [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) | Encrypt secrets as CRDs |
| [ESO (External Secrets Operator)](https://external-secrets.io/) | Sync Vault secrets to Kubernetes |
| [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) | Mount secrets directly into pods |
| [Vault](https://www.vaultproject.io/) | Backend secret storage and access control |
| [Vault Cli](https://www.vaultproject.io/) | Vault CLI |
---

## 📁 Directory Overview
```
kubernetes-secret-management/
├── app-manifests/ # Sample app manifests (Nginx)
├── external-secret-operator/ # Vault + ESO integration (K8s & Token auth)
├── sealed-secret/ # Sealed Secrets controller + sample SealedSecret
├── secret-store-csi-driver/ # CSI driver + Vault provider + pod-mounted secrets
├── sops/ # KSOPS integration using SOPS with Age/KMS
├── gitops/ # ArgoCD Applications for syncing each module
├── initial/ # ArgoCD bootstrap + custom repo-server image
└── README.md # This file
```

---

## 🔐 Modules Explained

### 1️⃣ `app-manifests/`

- A simple sample app (Nginx) with `Deployment` and `Service`
- Used for testing secret injection (env or mounted)

---

### 2️⃣ `external-secret-operator/`

- Installs ESO + Vault using Helmfile
- Supports both:
  - 🔐 Kubernetes Auth-based login to Vault
  - 🧾 Token Auth (Vault token sealed via SOPS)
- Includes ArgoCD syncable overlays

🗝️ Secrets are pulled into Kubernetes `Secret` resources from Vault KV backend.

---

### 3️⃣ `sealed-secret/`

- Installs Bitnami Sealed Secrets controller
- Converts encrypted SealedSecret CRDs into usable K8s Secrets
- Encrypted secrets are safe to store in Git

🔐 Secrets are **sealed via `kubeseal`** and decrypted only by the controller.

---

### 4️⃣ `secret-store-csi-driver/`

- Installs CSI driver + Vault provider via Helmfile
- Configures `SecretProviderClass` to mount Vault secrets into pods as volumes
- Avoids storing secrets in K8s altogether

🚫 No K8s Secret objects are created — secrets are ephemeral and mounted only.

---

### 5️⃣ `sops/`

- GitOps-friendly SOPS secret management
- Two options:
  - 🔐 `setup/age-key/` → Encrypt with Age key
  - 🛡️ `setup/kms/` → Encrypt with cloud KMS (AWS, GCP, Azure)
- Uses `ksops` plugin with ArgoCD
- Secrets decrypted at runtime using `.enc.yaml` and `secret-generator.yaml`

💡 Update `.sops.yaml` and ensure Age private key or KMS role access is properly configured.

---

### 6️⃣ `initial/`

- Bootstraps ArgoCD using Helmfile
- Patches ArgoCD to:
  - Support KSOPS plugin
  - Mount Age key / inject KMS config
- Includes `Dockerfile.argoreposerver` for custom image (with `sops`, `ksops`, `kustomize`, etc.)

🚀 Must be run before syncing any other modules if KSOPS or sealed secrets are used.

---

### 7️⃣ `gitops/`

Contains ArgoCD `Application` manifests for each module:

```yaml
- eso-app.yaml
- sealedsecret-app.yaml
- secret-store-csi-app.yaml
- sops-app.yaml
```


### 🔄 gitops/ – ArgoCD Application Manifests
This directory contains ArgoCD Application YAMLs, one for each module in this repository.

Each ArgoCD Application points to a specific folder (e.g., external-secret-operator/, sealed-secret/, etc.) and enables GitOps-style deployment.

💡 Users must manually apply these Application manifests in their own cluster.

```bash
kubectl apply -f gitops/
Available Applications:
ArgoCD App Manifest	Module Targeted
eso-app.yaml	external-secret-operator/
sealedsecret-app.yaml	sealed-secret/
secret-store-csi-app.yaml	secret-store-csi-driver/
sops-app.yaml	sops/
```

🔁 ArgoCD will continuously sync these modules from Git after the apps are created.

