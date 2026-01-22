#!/bin/bash
# KEDA Installation Script
# Run this on your Kubernetes cluster

echo "Installing KEDA via Helm..."

# Add KEDA Helm repo
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# Install KEDA in keda namespace
helm install keda kedacore/keda \
  --namespace keda \
  --create-namespace \
  --set prometheus.metricServer.enabled=true \
  --set prometheus.operator.enabled=false

echo "Waiting for KEDA to be ready..."
kubectl wait --for=condition=ready pod -l app=keda-operator -n keda --timeout=120s

echo "KEDA installation complete!"
kubectl get pods -n keda
