#!/bin/bash
# 5090 GPU Box Setup — Run once after fresh Ubuntu 24.04 install
# Usage: bash setup-5090.sh
set -e

echo "========================================="
echo "  5090 GPU Box Setup"
echo "  Ubuntu 24.04 + RTX 5090"
echo "========================================="

# 1. Nuke ALL existing nvidia packages first
echo "[1/7] Nuking all existing NVIDIA packages..."
sudo apt-get remove --purge '^nvidia-.*' -y 2>/dev/null || true
sudo apt-get remove --purge '^libnvidia-.*' -y 2>/dev/null || true
sudo apt-get remove --purge 'nvidia-*' -y 2>/dev/null || true
sudo apt-get autoremove --purge -y 2>/dev/null || true
sudo apt-get autoclean

# 2. Update system
echo "[2/7] Updating system..."
sudo apt update && sudo apt upgrade -y

# 3. Install build tools
echo "[3/7] Installing build tools..."
sudo apt install -y build-essential dkms linux-headers-$(uname -r) wget curl git openssh-server sshfs

# 4. Install NVIDIA driver 570 (required for RTX 5090)
echo "[4/7] Downloading NVIDIA driver 570..."
cd /tmp
wget -q --show-progress https://us.download.nvidia.com/XFree86/Linux-x86_64/570.133.07/NVIDIA-Linux-x86_64-570.133.07.run
chmod +x NVIDIA-Linux-x86_64-570.133.07.run
echo "Installing NVIDIA driver (this takes a few minutes)..."
sudo sh NVIDIA-Linux-x86_64-570.133.07.run --silent --dkms

# 5. Install Docker
echo "[5/7] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 6. Install Ollama
echo "[6/7] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
# Configure Ollama to listen on all interfaces
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<EOF2
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF2
sudo systemctl daemon-reload
sudo systemctl restart ollama

# 7. Install Tailscale
echo "[7/7] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "========================================="
echo "  DONE! Now do these two things:"
echo "========================================="
echo ""
echo "1. Reboot:  sudo reboot"
echo ""
echo "2. After reboot, log in and run:"
echo "   nvidia-smi"
echo "   sudo tailscale up"
echo ""
echo "   Tailscale will give you a URL."
echo "   Open it on your phone to authenticate."
echo "   Then run: tailscale ip"
echo "   Tell Tom the 100.x.x.x IP."
echo ""
echo "3. Pull models (after reboot):"
echo "   ollama pull nomic-embed-text"
echo "   ollama pull qwen2.5:7b"
echo ""
echo "========================================="
