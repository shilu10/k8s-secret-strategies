cat ~/.config/sops/age/keys.txt | kubectl create secret generic sops-age --namespace=argocd --from-file=keys.txt=/dev/stdin
