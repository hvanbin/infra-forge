#!/bin/bash

# Display warning
echo "WARNING: This script will delete all Forgejo-related PersistentVolumeClaims."
echo "This will result in PERMANENT DATA LOSS."
echo "Press Ctrl+C now to cancel, or wait 5 seconds to continue..."
sleep 5

# Get all PVCs related to Forgejo
FORGEJO_PVCS=$(kubectl get pvc -o name | grep forgejo)

if [ -z "$FORGEJO_PVCS" ]; then
  echo "No Forgejo PVCs found."
  exit 0
fi

echo "The following PVCs will be deleted:"
echo "$FORGEJO_PVCS"
echo ""
echo "Are you sure you want to continue? (yes/no)"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Operation cancelled."
  exit 0
fi

# Delete the PVCs
echo "Deleting PVCs..."
kubectl delete pvc $(kubectl get pvc -o name | grep forgejo | cut -d/ -f2)

# Delete the secrets
echo "Deleting Kubernetes secrets..."
kubectl delete secret forgejo-admin-secret forgejo-postgresql-secret 2>/dev/null || true

echo "PVCs and secrets deleted successfully."
echo "You can now reinstall Forgejo with a clean state."
