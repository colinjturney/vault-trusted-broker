#!/bin/bash

# Create policy for the app1 build job

cat <<EOF > app1_policy.hcl

# Allow app1 to retrieve secret from the secret KV store
path "secret/data/dev" {
  capabilities = ["read"]
}

EOF

vault policy write app1 app1_policy.hcl

# Write some test data at secret/dev that the wrapped secretID will allow access to

vault secrets enable -path=secret kv-v2

vault kv put secret/dev username="webapp" password="my-long-password"

# Create AppRole for app1_policy

vault write auth/approle/role/app1 \
    secret_id_ttl=10m \
    token_num_uses=1 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=1 \
    token_policies="app1"
