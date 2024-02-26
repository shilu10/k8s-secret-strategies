# /bin/bash


vault secrets enable -path=kv kv-v2


vault kv put kv/db url="dev.mysql.amazonaws.com"