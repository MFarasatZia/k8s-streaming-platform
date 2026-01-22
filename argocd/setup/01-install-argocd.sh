#!/bin/bash
set -e

echo "========================================="
echo "Installing ArgoCD on Kubernetes"
echo "========================================="

# Create namespace for ArgoCD
kubectl create namespace argocd || true

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-applicationset-controller -n argocd

echo "========================================="
echo "ArgoCD Installation Complete!"
echo "========================================="

# Get initial admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "ArgoCD Credentials:"
echo "  Username: admin"
echo "  Password: ${ARGOCD_PASSWORD}"
echo ""
echo "Access ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then open: https://localhost:8080"
echo ""
echo "Or expose via Ingress (see argocd-ingress.yaml)"
echo ""
echo "Install ArgoCD CLI:"
echo "  brew install argocd  # macOS"
echo "  # or download from https://github.com/argoproj/argo-cd/releases"
echo ""
echo "Login with CLI:"
echo "  argocd login localhost:8080 --username admin --password ${ARGOCD_PASSWORD} --insecure"
