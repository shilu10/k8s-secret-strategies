# 📦 app-manifest

This directory contains Kubernetes manifests to deploy a simple **NGINX** web server using a `Deployment` and `Service`, managed via **Kustomize**.

---

## 📁 Structure
```bash
app-manifest/
├── deployment.yaml
├── service.yaml
└── kustomization.yaml
```

---

## 🛠️ Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)  
  (or use `kubectl` with built-in Kustomize support)

---

## 🚀 Deployment Instructions

### 1. Deploy using Kustomize

```bash
kubectl apply -k .
