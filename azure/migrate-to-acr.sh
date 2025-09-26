#!/bin/bash

# Migrate Docker images to Azure Container Registry (ACR)
# This script pulls the original images and pushes them to your ACR

set -e

# Configuration - Update these variables
ACR_NAME="your-acr-name"
RESOURCE_GROUP="your-resource-group"

echo "=== Migrating Images to Azure Container Registry ==="

# Check if Azure CLI is authenticated
echo "Checking Azure CLI authentication..."
az account show > /dev/null || { echo "Please run 'az login' first"; exit 1; }

# Check if Docker is running
echo "Checking Docker..."
docker info > /dev/null || { echo "Please start Docker daemon"; exit 1; }

# Login to ACR
echo "Logging into ACR..."
az acr login --name $ACR_NAME

# Define image mappings
declare -A images=(
    ["kodekloud/examplevotingapp_vote:v1"]="$ACR_NAME.azurecr.io/examplevotingapp_vote:v1"
    ["kodekloud/examplevotingapp_result:v1"]="$ACR_NAME.azurecr.io/examplevotingapp_result:v1"
    ["kodekloud/examplevotingapp_worker:v1"]="$ACR_NAME.azurecr.io/examplevotingapp_worker:v1"
)

# Pull, tag, and push images
for source_image in "${!images[@]}"; do
    target_image="${images[$source_image]}"
    
    echo "Processing $source_image -> $target_image"
    
    # Pull original image
    echo "  Pulling $source_image..."
    docker pull $source_image
    
    # Tag for ACR
    echo "  Tagging as $target_image..."
    docker tag $source_image $target_image
    
    # Push to ACR
    echo "  Pushing to ACR..."
    docker push $target_image
    
    echo "  ✓ Completed $source_image"
done

echo "=== Migration Complete ==="
echo "Your images are now available in ACR:"
for target_image in "${images[@]}"; do
    echo "  - $target_image"
done

echo ""
echo "To use ACR images in your deployments:"
echo "1. Update the image references in your deployment files"
echo "2. Ensure your AKS cluster has permissions to pull from ACR"
echo "3. Run: az aks update -n your-aks-cluster -g $RESOURCE_GROUP --attach-acr $ACR_NAME"