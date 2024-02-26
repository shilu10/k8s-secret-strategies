#/bin/bash

vault write auth/kubernetes/role/app-k8s-role \
  bound_service_account_names=eso-sa \
  bound_service_account_namespaces=dev \
  policies=read-kv \
  ttl=1h