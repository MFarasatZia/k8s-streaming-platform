#!/bin/bash
set -e

echo "========================================="
echo "K3S Installation Script"
echo "Server Specs: 48 cores, 128GB RAM"
echo "========================================="

# Install k3s with recommended settings for your high-spec server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --write-kubeconfig-mode 644 \
  --kube-apiserver-arg default-not-ready-toleration-seconds=10 \
  --kube-apiserver-arg default-unreachable-toleration-seconds=10 \
  --kube-controller-arg node-monitor-period=10s \
  --kube-controller-arg node-monitor-grace-period=20s \
  --kubelet-arg=config=/etc/rancher/k3s/kubelet.yaml" sh -

# Wait for k3s to be ready
echo "Waiting for k3s to be ready..."
sleep 10

# Verify installation
echo "========================================="
echo "Verifying k3s installation..."
echo "========================================="
sudo k3s kubectl get nodes

# Set up kubectl for current user
mkdir -p ~/.kube
sudo cp /etc/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

# Configure NVIDIA runtime for k3s containerd
echo "========================================="
echo "Configuring NVIDIA runtime for k3s..."
echo "========================================="
if command -v nvidia-ctk &> /dev/null; then
    sudo nvidia-ctk runtime configure --runtime=containerd --config=/var/lib/rancher/k3s/agent/etc/containerd/config.toml
    sudo systemctl restart k3s
    echo "NVIDIA runtime configured for k3s"
else
    echo "WARNING: nvidia-ctk not found. Make sure to run fix-nvidia-toolkit.sh first!"
fi

echo "========================================="
echo "K3S Installation Complete!"
echo "========================================="
echo "Next steps:"
echo "1. Run: kubectl get nodes"
echo "2. Label your GPU node: kubectl label nodes <node-name> gpu=nvidia"
echo "3. Install NVIDIA GPU Operator (see 02-install-nvidia-gpu-operator.sh)"
