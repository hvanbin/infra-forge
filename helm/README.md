# Forgejo Helm Deployment

This repository contains configuration files for deploying Forgejo using Helm with persistent PostgreSQL and secure password management.

## Files

- `create-forgejo-secrets.sh`: Script to generate a random password for the Forgejo admin user
- `forgejo-values.yaml`: Custom values for the Forgejo Helm chart
- `purge-forgejo-pvs.sh`: Script to clean up persistent volumes if needed

## Deployment Instructions

### 1. Create Kubernetes Secrets

First, run the script to create the necessary Kubernetes secrets:

```bash
chmod +x create-forgejo-secrets.sh
./create-forgejo-secrets.sh
```

This script will:
- Generate random passwords for Forgejo admin, PostgreSQL, and pgpool
- Create Kubernetes secrets to store these passwords
- Display the Forgejo admin password (save this for later use)

**IMPORTANT**: You must run this script before installing or reinstalling Forgejo. If you uninstall and reinstall Forgejo without running this script again, the deployment will fail because the required secrets won't exist.

### 2. Install Forgejo with Helm

Install Forgejo using the custom values file:

```bash
helm install forgejo oci://code.forgejo.org/forgejo-helm/forgejo -f forgejo-values.yaml
```

### 3. Access Forgejo

Once the deployment is complete, you can access Forgejo by port-forwarding the service:

```bash
kubectl port-forward svc/forgejo-http 3000:3000
```

Then visit http://localhost:3000 in your browser.

Login with:
- Username: forgejo_admin
- Password: (the password displayed when you ran the create-forgejo-secrets.sh script)

## Configuration Details

### Persistence

- Forgejo data is stored in a persistent volume (10Gi)
- PostgreSQL data is stored in persistent volumes (10Gi)
- Redis data is stored in a persistent volume (8Gi)
- All persistence configurations are set to reuse existing PVCs if they exist, making the deployment easily redeployable without data loss

### Security

- The Forgejo admin password is stored in a Kubernetes secret
- PostgreSQL and pgpool passwords are stored in a Kubernetes secret
- Redis authentication is disabled for simplicity
- The application runs as a non-root user

### Resources

- Resource limits and requests are configured for better performance and stability

### Redeployability

- The configuration is designed to be easily redeployable
- If you uninstall and reinstall Forgejo, it will reuse existing PVCs, preserving your data
- All container images use `pullPolicy: Always` to ensure fresh images are pulled during reinstallation
- This means you can upgrade or reconfigure Forgejo without losing your repositories or settings

## Cleanup

If you need to completely remove the deployment and start fresh:

1. Uninstall the Helm release:
   ```bash
   helm uninstall forgejo
   ```

2. Delete the secrets:
   ```bash
   kubectl delete secret forgejo-admin-secret forgejo-postgresql-secret
   ```

3. If you need to delete the persistent volumes (WARNING: this will delete all data):
   ```bash
   chmod +x purge-forgejo-pvs.sh
   ./purge-forgejo-pvs.sh
   ```

## Reinstallation

If you need to reinstall Forgejo:

1. Uninstall the Helm release:
   ```bash
   helm uninstall forgejo
   ```

2. Recreate the secrets:
   ```bash
   ./create-forgejo-secrets.sh
   ```

3. Reinstall Forgejo:
   ```bash
   helm install forgejo oci://code.forgejo.org/forgejo-helm/forgejo -f forgejo-values.yaml
   ```
