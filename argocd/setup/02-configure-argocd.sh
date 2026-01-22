#!/bin/bash
set -e

echo "========================================="
echo "Configuring ArgoCD for GitOps"
echo "========================================="

# Variables - Update these for your environment
REPO_URL="${REPO_URL:-https://github.com/yourusername/devops-k8s-streaming-platform.git}"
ARGOCD_SERVER="localhost:8080"

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Logging into ArgoCD..."
argocd login ${ARGOCD_SERVER} --username admin --password ${ARGOCD_PASSWORD} --insecure

# Add the Git repository
echo "Adding Git repository..."
argocd repo add ${REPO_URL} --name streaming-platform

# Apply AppProject
echo "Creating AppProject..."
kubectl apply -f ../appprojects/streaming-platform-project.yaml

# Apply Applications
echo "Creating ArgoCD Applications..."
kubectl apply -f ../applications/

echo "========================================="
echo "ArgoCD Configuration Complete!"
echo "========================================="
echo ""
echo "View applications:"
echo "  argocd app list"
echo ""
echo "Sync all applications:"
echo "  argocd app sync api-app"
echo "  argocd app sync worker-app"
echo "  argocd app sync frontend-app"
echo ""
echo "Or use the ArgoCD UI at https://localhost:8080"
