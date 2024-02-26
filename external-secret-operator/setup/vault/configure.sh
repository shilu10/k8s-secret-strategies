vault auth enable kubernetes


vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


vault policy write read-kv read-kv.hcl


vault secrets enable -path=kv kv-v2


vault kv put kv/db url="dev.mysql.amazonaws.com"


vault write auth/kubernetes/role/app-k8s-role \
  bound_service_account_names=vault-provider-sa \
  bound_service_account_namespaces=dev \
  policies=read-kv \
  ttl=1h


#!/bin/bash

# Configurable values
VAULT_NAMESPACE="default"                   # Namespace where Vault is deployed
VAULT_POD=$(kubectl get pod -n "$VAULT_NAMESPACE" -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")

# Temp file for CA certificate
CA_CERT_PATH=$(mktemp)

# Read token and CA cert from Vault pod
TOKEN_REVIEWER_JWT=$(kubectl exec -n "$VAULT_NAMESPACE" "$VAULT_POD" -- \
  cat /var/run/secrets/kubernetes.io/serviceaccount/token)

kubectl exec -n "$VAULT_NAMESPACE" "$VAULT_POD" - -- \
  cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt > "$CA_CERT_PATH"

# Extract Kubernetes host from current context
KUBERNETES_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath="{.clusters[0].cluster.server}")

# Configure Vault Kubernetes Auth
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
  kubernetes_host="$KUBERNETES_HOST" \
  kubernetes_ca_cert=@"$CA_CERT_PATH"

# Clean up
rm -f "$CA_CERT_PATH"
