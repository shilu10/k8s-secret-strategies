# 🔐 GitOps with ArgoCD + ksops (age encryption) on KubeAdm

This project demonstrates secure secret management in Git using **SOPS** with **age encryption**, integrated into **Kustomize overlays**, and deployed via ArgoCD GitOps Operator on kubeadm cluster.

---

## 🗄️ Project Structure

```
.
├── base
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays
│   ├── dev
│   │   ├── secret.dev.enc.yaml
│   │   ├── secret-generator.yaml
│   │   ├── namespace.yaml
│   │   ├── patch.yaml
│   │   └── kustomization.yaml
│   └── prod
│       ├── secret.prod.enc.yaml
│       ├── secret-generator.yaml
│       ├── namespace.yaml
│       ├── patch.yaml
│       └── kustomization.yaml
└── setup
    ├── local-key
    │   ├── create-secret.sh
    │   ├── argo-cd-cm-patch.yaml
    │   └── argo-cd-repo-server-patch.yaml
    └── Kubernetes manifest configurations
```

---

## 🔧 Prerequisites

- Kubeadm or Kind cluster with GitOps Operator / ArgoCD installed
- Tools:
  - `sops` (v3.0+)
  - `age` (`age-keygen`)
  - `kubectl`
  - `kustomize`
  - `ksops` plugin enabled in ArgoCD

---

## 1. 🛠️ Setup Age Key
Install the [Age tool](https://github.com/FiloSottile/age#installation) and run the below command to generate a new key:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

Copy the **public key** from `keys.txt` (look for the `public key:` line).

---
## 2. Create a Secret 
Create a secret in the namespace where your ArgoCD-instance is running:
```bash
cat age.agekey | kubectl create secret generic sops-age --namespace=argocd \
--from-file=keys.txt=/dev/stdin
```

## 3. 🛡️ Configure SOPS

Create or edit `sops/.sops.yaml`:

```yaml
creation_rules:
  - encrypted_regex: '^(data|stringData)$'
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Replace `age1...` with your actual age public key.

---

## 4. 🔐 Encrypt Secret Overlays

Define a plaintext secret (e.g., `sops/overlays/dev/secret.dev.enc.yaml`):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: dev
type: Opaque
stringData:
  DB_USER: "devuser"
  DB_PASS: "devpass"
```

Encrypt it:

```bash
cd sops/
sops -e -i overlays/dev/secret.dev.enc.yaml
```

Repeat for `prod` overlay.

---

## 5. 🔓 Decrypt Locally (for testing)

```bash
cd sops/
sops -d overlays/dev/secret.dev.enc.yaml
```

If you encounter errors locating keys:

```bash
export SOPS_AGE_KEY="$(cat ~/.config/sops/age/keys.txt)"
```

---

## 6. ⚙️ Enable ksops in ArgoCD on Kubeadm or Kind Cluster

1. **Local age secret(private key)**:  
   Create a Kubernetes secret in the ArgoCD namespace (usually `argocd`):

   ```bash
   cat ~/.config/sops/age/keys.txt | kubectl create secret generic sops-age --namespace=argocd --from-file=keys.txt=/dev/stdin
   ```
   look into setup/age-key/create-secret.sh for reference.

2. **Patch ArgoCD ConfigMap**:

   ```bash
   kubectl patch configmap argocd-cm -n argocd --patch-file \
     setup/age-key/argo-cd-cm-patch.yaml
   ```

3. **Patch ArgoCD repo-server deployment**:

   ```bash
   kubectl patch deployment argocd-repo-server \
     -n argocd --patch-file setup/age-key/argo-cd-repo-server-patch.yaml
   ```

4. **Restart deployments**:

   ```bash
   kubectl rollout restart configmap/argocd-cm -n argocd
   kubectl rollout restart deployment/argocd-repo-server -n argocd
   kubectl rollout restart deployment/argocd-application-controller -n \ argocd
   ```

---

## 7. 🔁 Create ArgoCD Applications

Use GitOps Operator CRDs (e.g., `Application` ) to target:

- repo: your Git repository
- path: `sops/overlays/dev` or `sops/overlays/prod`
- namespace: `dev` / `prod`
- sync policy: manual or automated

ksops will decrypt secrets during rendering.

---

## 8. ✅ Validate

- ArgoCD UI (OCP Console or Grafana) shows successful sync.
- Secrets appear decrypted in your Dev/Prod namespaces.

---

## 9. 🔐 Rotation / Clean-up

- To revoke access, remove the `sops-age` secret or rotate your age key.
- Use `sops -r` to rekey existing encrypted files if needed.

---

## 10. 🎉 Benefits

- 👁️ No plaintext secrets in Git
- 🔄 Environment-specific overlays
- 🔐 Secure decryption using ArgoCD-sideage
- 🧠 Easy to replicate for OKD/OCP and vanilla Kubernetes

---
