## Example Voting App Kubernetes

This is based on the original [example-voting-app](https://github.com/dockersamples/example-voting-app) repository from the [docker-examples](https://github.com/dockersamples) GitHub page and modified it to work on the Kubernetes cluster.

### Azure Compatibility ✅

**Yes, this application works with Azure!** This repository includes full Azure support:

- **Azure Kubernetes Service (AKS)** - Fully compatible
- **Azure Container Registry (ACR)** - Migration scripts provided
- **Azure Load Balancer** - Optimized service configurations
- **Azure Managed Disks** - Persistent storage for PostgreSQL

See the [Azure deployment guide](./azure/README-Azure.md) for detailed instructions.

## Quick Start

### Standard Kubernetes Deployment
```bash
kubectl apply -f .
```

### Azure Kubernetes Service (AKS) Deployment
```bash
cd azure
./deploy-to-aks.sh
```

## Architecture

The application consists of:
- **Voting App** - Frontend web app for casting votes
- **Result App** - Web app for viewing results
- **Worker** - Background service processing votes
- **Redis** - In-memory database for vote queueing
- **PostgreSQL** - Database for storing vote results

## Files

- `*-deploy.yaml` - Kubernetes deployments
- `*-service.yaml` - Kubernetes services
- `azure/` - Azure-specific configurations and deployment scripts

