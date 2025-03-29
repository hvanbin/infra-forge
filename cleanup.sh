#!/bin/bash

# Exit on error
set -e

echo "Cleaning up Forgejo Kubernetes deployment..."

# Delete Forgejo
echo "Deleting Forgejo..."
kubectl delete -f 07-forgejo-deployment.yaml --ignore-not-found

# Delete PostgreSQL
echo "Deleting PostgreSQL..."
kubectl delete -f 06-postgres-deployment.yaml --ignore-not-found

# Delete secrets and configmaps
echo "Deleting secrets and configmaps..."
kubectl delete -f 05-forgejo-secret.yaml --ignore-not-found
kubectl delete -f 04-forgejo-configmap.yaml --ignore-not-found
kubectl delete -f 03-postgres-secret.yaml --ignore-not-found

# Delete persistent volume claims
echo "Deleting persistent volume claims..."
kubectl delete -f 02-postgres-pv-pvc.yaml --ignore-not-found
kubectl delete -f 01-forgejo-pv-pvc.yaml --ignore-not-found

# Delete namespace (this will delete all resources in the namespace)
echo "Deleting namespace..."
kubectl delete -f 00-namespace.yaml --ignore-not-found

echo "Cleanup completed successfully!"
echo "Note: The persistent data on the host at '/mnt/data/forgejo' and '/mnt/data/postgres' has not been deleted."
