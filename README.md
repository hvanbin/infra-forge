# Forgejo Kubernetes Deployment

This directory contains Kubernetes manifests to deploy Forgejo with a PostgreSQL database.
A lot of extras, like security policies and resource constraints have been added.

For reference, a simple `compose` and an even more complex `helm` version are included.

## Prerequisites

- Kubernetes cluster
- kubectl configured to communicate with your cluster
- Storage provisioner that supports ReadWriteOnce access mode (or modify the PV/PVC definitions accordingly)

## Deployment

`kubectl apply -k.`

## Cleanup

`kubectl delete -k.`

This will delete all resources in the reverse order of creation. Note that the persistent data on the host at `/mnt/data/forgejo` and `/mnt/data/postgres` will not be deleted.

## Accessing Forgejo

Forgejo is accessible through an Ingress:
- HTTP: https://forgejo.binning.dev

Future enhancements include SSH from Forgejo for repos, runners, and more customization.

## Persistent Data

The following data is persisted:
- Forgejo data: `/mnt/data/forgejo` on the host
- PostgreSQL data: `/mnt/data/postgres` on the host

Make sure these directories exist and have appropriate permissions on your Kubernetes nodes.

# Upgrades to Forgejo and Postgres

1. Test new versions in development environment
2. Backup data before upgrading
3. Update version numbers in deployment files
4. Apply rolling updates
5. Verify functionality