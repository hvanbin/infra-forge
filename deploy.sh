#!/bin/bash

# Exit on error
set -e

echo "Deploying Forgejo to Kubernetes..."

# Create namespace
echo "Creating namespace..."
kubectl apply -f 00-namespace.yaml

# Create persistent volumes and claims
echo "Creating persistent volumes and claims..."
kubectl apply -f 01-forgejo-pv-pvc.yaml
kubectl apply -f 02-postgres-pv-pvc.yaml

# Create secrets and configmaps
echo "Creating secrets and configmaps..."
kubectl apply -f 03-postgres-secret.yaml
kubectl apply -f 04-forgejo-configmap.yaml
kubectl apply -f 05-forgejo-secret.yaml

# Deploy PostgreSQL
echo "Deploying PostgreSQL..."
kubectl apply -f 06-postgres-deployment.yaml

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl -n forgejo wait --for=condition=available --timeout=300s deployment/postgres

# Deploy Forgejo
echo "Deploying Forgejo..."
kubectl apply -f 07-forgejo-deployment.yaml

# Wait for Forgejo to be ready
echo "Waiting for Forgejo to be ready..."
kubectl -n forgejo wait --for=condition=available --timeout=300s deployment/forgejo

echo "Deployment completed successfully!"
echo "Forgejo is accessible at:"
echo "  - HTTP: http://forgejo.localhost"
echo "  - SSH: NodeIP:22"
echo ""
echo "Note: Make sure 'forgejo.localhost' is added to your /etc/hosts file pointing to your cluster IP"
