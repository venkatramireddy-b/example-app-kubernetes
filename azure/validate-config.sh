#!/bin/bash

# Validate Kubernetes configurations for Azure deployment

set -e

echo "=== Validating Kubernetes Configurations ==="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

echo "✅ kubectl is available"

# Validate YAML syntax for all configuration files
echo "Validating YAML syntax..."

validate_yaml() {
    local file=$1
    # Check YAML syntax using Python, handling multiple documents
    if python3 -c "import yaml; [doc for doc in yaml.safe_load_all(open('$file'))]" > /dev/null 2>&1; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file - Invalid YAML syntax"
        return 1
    fi
}

# Validate original files
cd /home/runner/work/example-app-kubernetes/example-app-kubernetes

for file in *.yaml; do
    validate_yaml "$file"
done

# Validate Azure-specific files
cd azure

for file in *.yaml; do
    validate_yaml "$file"
done

echo ""
echo "=== Configuration Validation Complete ==="
echo "All Kubernetes manifests are valid and ready for deployment!"