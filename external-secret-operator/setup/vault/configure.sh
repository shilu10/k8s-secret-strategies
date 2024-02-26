vault auth enable kubernetes


vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


vault policy write read-kv read-kv.hcl


vault secrets enable -path=kv kv-v2


vault kv put kv/db url="dev.mysql.amazonaws.com"


vault write auth/kubernetes/role/app-k8s-role \
  bound_service_account_names=eso-sa \
  bound_service_account_namespaces=dev \
  policies=read-kv \
  ttl=1h