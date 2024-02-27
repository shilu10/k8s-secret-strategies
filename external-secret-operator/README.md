# 🔐 External Secret Operator Setup with Vault (Dev Overlay)

This repository automates the integration of **External Secrets Operator (ESO)** with **HashiCorp Vault** in a Kubernetes cluster using **Helmfile** and **Kustomize**.

---

## 📁 Directory Structure

```bash
external-secret-operator/
├── README.md
├── overlays/
│ └── dev/
│ ├── namespace.yaml
│ ├── sa.yaml
│ ├── k8s-auth-secret-store.yaml
│ ├── k8s-auth-external-secret.yaml
│ ├── token-auth-secret-store.yaml
│ ├── token-auth-external-secret.yaml
│ ├── vault-secret.yaml
│ └── kustomization.yaml
└── setup/
├── cluster-bootstrap/
│ ├── helmfile.yaml
│ ├── environments/dev.yaml
│ └── values/
│ ├── external-secrets/dev-values.yaml
│ └── vault/dev-values.yaml
├── sops/
└── vault/
├── configure.sh
├── configure-k8s-auth.sh
├── create-policy.sh
├── create-k8s-role.sh
├── add-secret.sh
└── read-kv.hcl
```

---

## 🚀 Workflow Overview

1. ✅ Install Vault and ESO via **Helmfile**
2. ⚙️ Configure Vault with both **Kubernetes Auth** and **Policy**
3. 🔒 Encrypt Vault token using **SOPS**
4. 🔄 Sync manifests using **ArgoCD**
5. 📥 External Secrets Operator injects Vault secrets into Kubernetes

---

## 🔐 Authentication Modes

### 1. Kubernetes Auth (Dynamic)

- Vault uses Kubernetes SA token for auth.
- Resources:
  - `sa.yaml`
  - `k8s-auth-secret-store.yaml`
  - `k8s-auth-external-secret.yaml`

### 2. Token Auth (Static + Encrypted via SOPS)

- Vault token stored in a Kubernetes Secret.
- The token is encrypted using **SOPS** and checked into Git.
- Resources:
  - `sops-sealed-vault-token.yaml`
  - `token-auth-secret-store.yaml`
  - `token-auth-external-secret.yaml`

---

## 🛠️ Prerequisites

### - go to initial/ and install it.

---

## 1️⃣ Install Vault & ESO via Helmfile

```bash
cd setup/cluster-bootstrap
helmfile -e dev apply
```

- HashiCorp Vault (via Helm)

- External Secrets Operator (via Helm)

Configuration values from values/vault/dev-values.yaml and values/external-secrets/dev-values.yaml

## 2️⃣ Configure Vault 

```bash
cd setup/vault

./configure.sh
./configure-k8s-auth.sh
./create-policy.sh
./create-k8s-role.sh
./add-secret.sh
```

## 3️⃣ Encrypt Vault Token with SOPS

🔒 We use SOPS to encrypt the Vault token so it can be safely stored in Git and used for token-based auth.

### ✅ 3.1 Configure .sops.yaml with Your Public Key
Before encrypting anything, update the external-secret-operator/setup/sops/.sops.yaml file with your own Age or GPG public key:

Example (.sops.yaml) for Age:
```yaml
creation_rules:
  - path_regex: .*\.yaml$
    encrypted_regex: ^(data|stringData)$
    age:
      - age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

🔁 Replace the age public key with your own key.
You can generate a new Age key pair with:

```bash
age-keygen -o age.key > /dev/null
cat age.key | grep public
```
✅ Only commit .sops.yaml to Git — never commit age.key.


### 1. Create a secret:

```bash
kubectl create secret generic vault-token \
  --from-literal=token=<your-vault-token> \
  --dry-run=client -o yaml > plaintext-token.yaml
```

### 2. Encrypt it using SOPS:

```bash
sops -e plaintext-token.yaml > overlays/dev/sops-sealed-vault-token.yaml
rm plaintext-token.yaml
```

## 4️⃣ Sync via ArgoCD

### ArgoCD is used to automatically apply everything in overlays/dev/.

### Example ArgoCD Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: external-secrets-dev
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/external-secret-operator.git
    path: overlays/dev
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: external-secrets
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```