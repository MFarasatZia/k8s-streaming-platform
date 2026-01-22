#!/bin/bash
set -e

echo "========================================="
echo "Installing Prerequisites for K3S + GPU"
echo "========================================="

# Update system
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Install NVIDIA drivers
echo "========================================="
echo "NVIDIA Driver Installation"
echo "========================================="
if nvidia-smi &> /dev/null; then
    echo "NVIDIA drivers already installed:"
    nvidia-smi
else
    echo "Installing NVIDIA drivers..."
    sudo apt install -y ubuntu-drivers-common
    sudo ubuntu-drivers autoinstall

    echo "========================================="
    echo "NVIDIA drivers installed!"
    echo "PLEASE REBOOT YOUR SERVER NOW:"
    echo "  sudo reboot"
    echo "Then run this script again to verify."
    echo "========================================="
    exit 0
fi

# Install NVIDIA Container Toolkit
echo "========================================="
echo "Installing NVIDIA Container Toolkit..."
echo "========================================="

# Remove old repository file if exists
sudo rm -f /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Add NVIDIA Container Toolkit repository (new method)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# For Ubuntu/Debian - use the stable deb repository
echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/\$(ARCH) /" | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Install Helm
echo "========================================="
echo "Installing Helm..."
echo "========================================="
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm already installed: $(helm version --short)"
fi

echo "========================================="
echo "Prerequisites Installation Complete!"
echo "========================================="
echo "System is ready for k3s installation."
echo "Run: bash 01-install-k3s.sh"
