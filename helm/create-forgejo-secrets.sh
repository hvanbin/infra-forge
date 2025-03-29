#!/bin/bash

# Generate random passwords
FORGEJO_ADMIN_PASSWORD=$(openssl rand -base64 12)
POSTGRESQL_PASSWORD=$(openssl rand -base64 12)
REPMGR_PASSWORD=$(openssl rand -base64 12)
POSTGRES_PASSWORD=$(openssl rand -base64 12)
PGPOOL_ADMIN_PASSWORD=$(openssl rand -base64 12)

# Create Kubernetes secret for Forgejo admin
kubectl create secret generic forgejo-admin-secret \
  --from-literal=username=forgejo_admin \
  --from-literal=password="$FORGEJO_ADMIN_PASSWORD"

# Create Kubernetes secret for PostgreSQL and pgpool
kubectl create secret generic forgejo-postgresql-secret \
  --from-literal=password="$POSTGRESQL_PASSWORD" \
  --from-literal=repmgr-password="$REPMGR_PASSWORD" \
  --from-literal=postgres-password="$POSTGRES_PASSWORD" \
  --from-literal=pgpool-admin-password="$PGPOOL_ADMIN_PASSWORD"

echo "Secrets created successfully!"
echo "Forgejo admin username: forgejo_admin"
echo "Forgejo admin password: $FORGEJO_ADMIN_PASSWORD"
echo ""
echo "PostgreSQL passwords have been stored in the 'forgejo-postgresql-secret' Kubernetes secret"
