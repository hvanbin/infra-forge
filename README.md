# Forgejo Kubernetes Deployment

This directory contains Kubernetes manifests to deploy Forgejo with a PostgreSQL database.

## Prerequisites

- Kubernetes cluster
- kubectl configured to communicate with your cluster
- Storage provisioner that supports ReadWriteOnce access mode (or modify the PV/PVC definitions accordingly)

## Deployment

You can deploy Forgejo using the provided script:

```bash
# Make the script executable (if not already)
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

This script will apply all the manifests in the correct order and wait for the deployments to be ready.

Alternatively, you can apply the manifests manually in the following order:

```bash
# Create namespace
kubectl apply -f 00-namespace.yaml

# Create persistent volumes and claims
kubectl apply -f 01-forgejo-pv-pvc.yaml
kubectl apply -f 02-postgres-pv-pvc.yaml

# Create secrets and configmaps
kubectl apply -f 03-postgres-secret.yaml
kubectl apply -f 04-forgejo-configmap.yaml
kubectl apply -f 05-forgejo-secret.yaml

# Deploy PostgreSQL
kubectl apply -f 06-postgres-deployment.yaml

# Deploy Forgejo
kubectl apply -f 07-forgejo-deployment.yaml
```

## Cleanup

To remove all the Kubernetes resources created by this deployment, you can use the provided cleanup script:

```bash
# Make the script executable (if not already)
chmod +x cleanup.sh

# Run the cleanup script
./cleanup.sh
```

This script will delete all resources in the reverse order of creation. Note that the persistent data on the host at `/mnt/data/forgejo` and `/mnt/data/postgres` will not be deleted.

## Accessing Forgejo

Forgejo is accessible through an Ingress:
- HTTP: http://forgejo.localhost
- SSH: NodeIP:22

Make sure to add `forgejo.localhost` to your `/etc/hosts` file pointing to your cluster IP.

For production use, consider setting up a proper domain name and TLS certificates.

## Persistent Data

The following data is persisted:
- Forgejo data: `/mnt/data/forgejo` on the host
- PostgreSQL data: `/mnt/data/postgres` on the host

Make sure these directories exist and have appropriate permissions on your Kubernetes nodes.

## Security Considerations

For production use, consider:
- Using a proper secret management solution instead of storing secrets in YAML files
- Setting up TLS for secure communication
- Configuring resource limits appropriate for your environment
- Using a dedicated storage solution instead of hostPath volumes

## Troubleshooting

### Bad Gateway Errors

If you experience "Bad Gateway" errors when accessing Forgejo, it might be due to endpoint issues. The deployment has been configured to use specific pod labels to ensure proper service routing. If you still encounter issues:

1. Check the endpoints:
   ```bash
   kubectl get endpoints -n forgejo
   ```
   
   The forgejo-svc endpoint should show only one IP address.

2. If multiple IP addresses are shown, you can fix it by:
   ```bash
   # Delete the endpoints and let Kubernetes recreate them
   kubectl delete endpoints forgejo-svc -n forgejo
   
   # Restart the Forgejo deployment
   kubectl rollout restart deployment forgejo -n forgejo
   ```

3. Verify the service selector matches the pod labels:
   ```bash
   # Check pod labels
   kubectl get pods -n forgejo --show-labels
   
   # Check service selector
   kubectl describe svc forgejo-svc -n forgejo
   ```

### Database Connection Issues

If Forgejo can't connect to the database:

1. Check if the PostgreSQL pod is running:
   ```bash
   kubectl get pods -n forgejo -l component=postgres
   ```

2. Check the PostgreSQL logs:
   ```bash
   kubectl logs -n forgejo $(kubectl get pods -n forgejo -l component=postgres -o jsonpath="{.items[0].metadata.name}")
   ```

3. Verify the database credentials in the secrets match what Forgejo is configured to use.
