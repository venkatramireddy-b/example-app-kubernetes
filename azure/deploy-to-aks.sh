#!/bin/bash

# Deploy Example Voting App to Azure Kubernetes Service (AKS)
# Prerequisites: Azure CLI installed and authenticated, kubectl configured for AKS cluster

set -e

# Configuration - Update these variables
RESOURCE_GROUP="your-resource-group"
ACR_NAME="your-acr-name"
AKS_CLUSTER_NAME="your-aks-cluster"
LOCATION="eastus"

echo "=== Deploying Example Voting App to AKS ==="

# Check if Azure CLI is authenticated
echo "Checking Azure CLI authentication..."
az account show > /dev/null || { echo "Please run 'az login' first"; exit 1; }

# Check if kubectl is configured
echo "Checking kubectl configuration..."
kubectl cluster-info > /dev/null || { echo "Please configure kubectl for your AKS cluster"; exit 1; }

# Apply standard deployments (works with original images)
echo "Deploying Redis..."
kubectl apply -f ../redis-deploy.yaml
kubectl apply -f ../redis-service.yaml

echo "Deploying PostgreSQL with Azure managed disk..."
kubectl apply -f postgres-deploy-azure.yaml
kubectl apply -f ../postgres-service.yaml

echo "Deploying applications..."
kubectl apply -f ../voting-app-deploy.yaml
kubectl apply -f ../result-app-deploy.yaml
kubectl apply -f ../worker-app-deploy.yaml

echo "Deploying services with LoadBalancer..."
kubectl apply -f voting-app-service-lb.yaml
kubectl apply -f result-app-service-lb.yaml

echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/redis-deploy
kubectl wait --for=condition=available --timeout=300s deployment/postgres-deploy
kubectl wait --for=condition=available --timeout=300s deployment/voting-app-deploy
kubectl wait --for=condition=available --timeout=300s deployment/result-app-deploy
kubectl wait --for=condition=available --timeout=300s deployment/worker-app-deploy

echo "Getting service endpoints..."
echo "Voting App:"
kubectl get service voting-service
echo "Result App:"
kubectl get service result-service

echo "=== Deployment Complete ==="
echo "Note: It may take a few minutes for LoadBalancer IPs to be assigned"
echo "Use 'kubectl get services' to check the external IPs"