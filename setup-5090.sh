#!/bin/bash
# 5090 GPU Box Setup — BULLETPROOF edition
# Usage: bash setup-5090.sh
# Handles broken dpkg, old nvidia, everything.

echo "========================================="
echo "  5090 GPU Box Setup — BULLETPROOF"
echo "========================================="

# Fix any broken dpkg state
echo "[1/7] Fixing package manager..."
sudo dpkg --configure -a
sudo apt-get install -f -y

# Nuke ALL nvidia packages
echo "[2/7] Nuking all NVIDIA packages..."
sudo apt-get remove --purge '^nvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge '^libnvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge 'nvidia-*' -y 2>/dev/null
sudo apt-get remove --purge 'cuda*' -y 2>/dev/null
sudo dpkg --configure -a
sudo apt-get autoremove --purge -y
sudo apt-get autoclean

# Update system
echo "[3/7] Updating system..."
sudo apt update
sudo apt upgrade -y

# Install build tools
echo "[4/7] Installing build tools..."
sudo apt install -y build-essential dkms linux-headers-$(uname -r) wget curl git openssh-server sshfs

# Download and install NVIDIA driver 570
echo "[5/7] Installing NVIDIA driver 570 for RTX 5090..."
cd /tmp
if [ ! -f NVIDIA-Linux-x86_64-570.133.07.run ]; then
    wget https://us.download.nvidia.com/XFree86/Linux-x86_64/570.133.07/NVIDIA-Linux-x86_64-570.133.07.run
fi
chmod +x NVIDIA-Linux-x86_64-570.133.07.run
sudo sh NVIDIA-Linux-x86_64-570.133.07.run --silent --dkms
if [ $? -ne 0 ]; then
    echo "Driver install failed. Trying without dkms..."
    sudo sh NVIDIA-Linux-x86_64-570.133.07.run --silent --no-dkms
fi

# Install Docker
echo "[6/7] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Ollama + configure
echo "[6/7] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat <<OLLAMACONF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
OLLAMACONF
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Install Tailscale
echo "[7/7] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "========================================="
echo "  DONE. Now run these commands:"
echo "========================================="
echo ""
echo "  sudo reboot"
echo ""
echo "  (after reboot, log back in, then:)"
echo ""
echo "  nvidia-smi"
echo "  sudo tailscale up"
echo "  tailscale ip"
echo "  ollama pull nomic-embed-text"
echo "  ollama pull qwen2.5:7b"
echo ""
echo "========================================="
