#!/bin/bash

# Create a policy for Jenkins

cat <<EOF > jenkins-master-policy.hcl

# Allow Jenkins to read from the secret KV store
path "secret/*" {
  capabilities = ["read", "list"]
}

# Allow Jenkins to create wrapped secret-ids

path "auth/approle/role/app1/*" {
  capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

EOF

vault policy write jenkins-master jenkins-master-policy.hcl

# Configure Jenkins AppRole and copy it to /vagrant

vault auth enable approle

# Create the Jenkins AppRole

# vault write auth/approle/role/jenkins \
#     secret_id_ttl=10m \
#     token_num_uses=10 \
#     token_ttl=20m \
#     token_max_ttl=30m \
#     secret_id_num_uses=40 \
#     token_policies="jenkins"

vault write auth/approle/role/jenkins-master \
    token_num_uses=0 \
    token_ttl=0 \
    token_max_ttl=0 \
    secret_id_num_uses=0 \
    token_policies="jenkins-master"


# Fetch the RoleId of the AppRole

vault read auth/approle/role/jenkins-master/role-id | grep role_id | cut -f5 -d' ' > /vagrant/jenkins-master-approle-role-id

# Get a SecretID issued against the AppRole

vault write -f auth/approle/role/jenkins-master/secret-id | grep secret_id | grep -v accessor | cut -f14 -d' ' > /vagrant/jenkins-master-approle-secret-id
