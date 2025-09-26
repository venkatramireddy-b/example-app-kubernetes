# Azure Deployment Guide

## Overview
This directory contains Azure-specific configurations and deployment scripts for the Example Voting App on Azure Kubernetes Service (AKS).

## Does it work on Azure repo source?

**Yes, this application works with Azure!** This guide provides everything needed to deploy the Example Voting App on Azure infrastructure.

## Azure Compatibility

### ✅ What Works Out of the Box
- All Kubernetes manifests are compatible with AKS
- Standard Docker images work without modification
- Application functionality is fully preserved

### 🔧 Azure Optimizations Provided
- **Azure Container Registry (ACR)** integration
- **Azure Load Balancer** services instead of NodePort
- **Azure Managed Disks** for persistent storage
- **Resource limits** for cost optimization
- **Automated deployment scripts**

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Docker** installed and running
3. **kubectl** configured for your AKS cluster
4. **Azure subscription** with appropriate permissions

## Quick Deploy (Original Images)

For immediate deployment using the original images:

```bash
# Deploy using original configuration with Azure optimizations
./deploy-to-aks.sh
```

This will:
- Deploy all services with Azure Load Balancers
- Use Azure managed disks for PostgreSQL storage
- Configure resource limits for cost efficiency

## Full Azure Integration

### Step 1: Create Azure Resources

```bash
# Set variables
RESOURCE_GROUP="voting-app-rg"
LOCATION="eastus"
ACR_NAME="votingappacr$(date +%s)"
AKS_NAME="voting-app-aks"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create ACR
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME

# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
```

### Step 2: Migrate Images to ACR

```bash
# Update the ACR name in migrate-to-acr.sh
# Then run:
./migrate-to-acr.sh
```

### Step 3: Deploy with ACR Images

```bash
# Update ACR name in the *-acr.yaml files
# Then deploy:
kubectl apply -f redis-deploy.yaml
kubectl apply -f redis-service.yaml
kubectl apply -f postgres-deploy-azure.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f voting-app-deploy-acr.yaml
kubectl apply -f result-app-deploy-acr.yaml
kubectl apply -f worker-app-deploy-acr.yaml
kubectl apply -f voting-app-service-lb.yaml
kubectl apply -f result-app-service-lb.yaml
```

## File Reference

### Azure-Optimized Deployments
- `voting-app-deploy-acr.yaml` - Voting app with ACR image and resource limits
- `result-app-deploy-acr.yaml` - Result app with ACR image and resource limits
- `worker-app-deploy-acr.yaml` - Worker app with ACR image and resource limits
- `postgres-deploy-azure.yaml` - PostgreSQL with Azure managed disk PVC

### Azure-Optimized Services
- `voting-app-service-lb.yaml` - Voting service with Azure Load Balancer
- `result-app-service-lb.yaml` - Result service with Azure Load Balancer

### Deployment Scripts
- `deploy-to-aks.sh` - Complete deployment automation
- `migrate-to-acr.sh` - Image migration to ACR

## Azure-Specific Features

### Load Balancer Configuration
- Uses Azure Load Balancer for external access
- Automatic public IP assignment
- Support for Azure Load Balancer annotations

### Storage
- Azure managed disks for PostgreSQL persistence
- CSI driver integration (`managed-csi` storage class)
- Automatic provisioning and backup capabilities

### Container Registry
- Private image hosting in ACR
- Integrated authentication with AKS
- Vulnerability scanning available

### Resource Management
- CPU and memory limits defined
- Cost optimization through right-sizing
- Horizontal Pod Autoscaler ready

## Monitoring and Troubleshooting

### Check Deployment Status
```bash
kubectl get pods
kubectl get services
kubectl get pv,pvc
```

### View Logs
```bash
kubectl logs -l app=demo-voting-app
```

### Access Applications
```bash
# Get external IPs
kubectl get services voting-service result-service

# Access via browser using the EXTERNAL-IP addresses
```

## Cost Optimization

- Uses `Standard_B2s` VMs for cost efficiency
- Resource limits prevent over-provisioning
- Single replica configuration (scale as needed)
- Basic ACR tier for development

## Security Considerations

- ACR provides private image hosting
- Network policies can be applied
- Azure AD integration available
- Key Vault integration for secrets

## Scaling

```bash
# Scale deployments
kubectl scale deployment voting-app-deploy --replicas=3
kubectl scale deployment result-app-deploy --replicas=2

# Enable autoscaling
kubectl autoscale deployment voting-app-deploy --cpu-percent=70 --min=1 --max=10
```

## Support

For Azure-specific issues:
- Review [AKS documentation](https://docs.microsoft.com/en-us/azure/aks/)
- Check [ACR documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- Use `kubectl describe` for detailed error information