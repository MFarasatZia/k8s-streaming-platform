#!/bin/bash
set -e

echo "========================================="
echo "Installing Monitoring Stack"
echo "Prometheus + Grafana + DCGM Exporter"
echo "========================================="

# Create monitoring namespace
kubectl create namespace monitoring || true

# Add Prometheus community Helm repo
echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (Prometheus + Grafana)
echo "Installing kube-prometheus-stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30080 \
  --wait

# Install DCGM Exporter for GPU metrics
echo "Installing NVIDIA DCGM Exporter for GPU monitoring..."
helm upgrade --install dcgm-exporter nvidia/dcgm-exporter \
  --namespace gpu-operator-resources \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.namespace=monitoring \
  --wait

# Create ServiceMonitor for application
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: youtubr-api-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: youtubr-api
  namespaceSelector:
    matchNames:
    - youtubr-automation
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
EOF

echo "========================================="
echo "Monitoring Stack Installation Complete!"
echo "========================================="

# Get Grafana access info
GRAFANA_PASSWORD=$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo ""
echo "Access Grafana at: http://${NODE_IP}:30080"
echo "Username: admin"
echo "Password: ${GRAFANA_PASSWORD}"
echo ""
echo "Recommended Grafana Dashboards:"
echo "1. NVIDIA DCGM Exporter Dashboard: ID 12239"
echo "2. Kubernetes / Compute Resources / Pod: ID 6417"
echo "3. Node Exporter Full: ID 1860"
echo ""
echo "To import dashboards:"
echo "1. Login to Grafana"
echo "2. Click + icon > Import"
echo "3. Enter dashboard ID and click Load"
echo "4. Select Prometheus as data source"
echo ""
echo "Port forwarding command for local access:"
echo "kubectl port-forward -n monitoring svc/prometheus-grafana 3001:80"
