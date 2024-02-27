# 🔐 Vault CSI Secrets Store Driver Setup (Dev Overlay)

This repository configures the **Secrets Store CSI Driver** in Kubernetes with **HashiCorp Vault** as the backend using **Kubernetes ServiceAccount-based authentication**.

The setup allows mounting Vault secrets directly into pods as ephemeral volumes — without writing secrets to Kubernetes Secrets.

---

## 📁 Directory Structure

```bash
├── README.md
├── overlays/
│ └── dev/
│ ├── kustomization.yaml
│ ├── namespace.yaml
│ ├── sa.yaml # ServiceAccount used by workloads
│ ├── secretprovider.yaml # SecretProviderClass binding Vault + SA
│ └── patches/
│ ├── remove-env.yaml # Removes inline env-based secrets
│ └── volume-mount.yaml # Adds volume + mount from CSI
└── setup/
├── cluster-bootstrap/
│ ├── helmfile.yaml # Installs CSI driver + Vault provider
│ ├── environments/dev.yaml
│ └── values/
│ ├── secret-store/dev-values.yaml # Values for CSI driver & Vault provider
│ └── vault/dev-values.yaml # Vault server chart values (optional)
└── vault/
├── configure-k8s-auth.sh # Enables Vault Kubernetes auth method
├── create-policy.sh # Vault policy to allow secret read
├── create-k8s-role.sh # Vault role mapped to K8s SA
├── add-secret.sh # Adds test KV secret to Vault
└── read-kv.hcl # Vault policy file
```


---

## 🛠️ Prerequisites

### go to initial/ and install all necessary tool and bootstrap the cluster.

---

## 🚀 Setup Instructions

### 1️⃣ Install CSI Driver & Vault Provider

```bash
cd setup/cluster-bootstrap
helmfile -e dev apply
```
Installs:

- Secrets Store CSI Driver (Azure/secrets-store-csi-driver)

- HashiCorp Vault provider

- Optional: Vault Helm chart (if included)

### 2️⃣ Configure Vault

```bash
cd setup/vault

# Enable Kubernetes auth & configure it
./configure-k8s-auth.sh

# Create Vault read policy
./create-policy.sh

# Create Vault role linked to Kubernetes ServiceAccount
./create-k8s-role.sh

# Add test KV secret
./add-secret.sh

```
