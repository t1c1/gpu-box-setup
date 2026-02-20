#!/bin/bash
# 5090 GPU Box Setup — v4 FINAL
# Key insight: RTX 5090 ONLY works with nvidia-driver-570-open from PPA
# NOT the .run file. NOT the proprietary driver. OPEN driver only.

echo "========================================="
echo "  5090 GPU Box Setup v4 FINAL"
echo "  Ubuntu 24.04 + RTX 5090"
echo "========================================="

# Fix any broken dpkg state
echo "[1/9] Fixing package manager..."
sudo dpkg --configure -a
sudo apt-get install -f -y

# Nuke ALL nvidia
echo "[2/9] Nuking all NVIDIA..."
sudo apt-get remove --purge '^nvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge '^libnvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge 'cuda*' -y 2>/dev/null
sudo dpkg --configure -a
sudo apt-get autoremove --purge -y
sudo apt-get autoclean
sudo rm -rf /usr/local/cuda* 2>/dev/null

# Update system
echo "[3/9] Updating system..."
sudo apt update
sudo apt upgrade -y

# Install newer kernel (6.8 is too old for 5090)
echo "[4/9] Installing HWE kernel..."
sudo apt install -y linux-generic-hwe-24.04

# Install build tools
echo "[5/9] Installing build tools..."
sudo apt install -y build-essential wget curl git openssh-server sshfs software-properties-common

# Add NVIDIA PPA and install open driver
echo "[6/9] Installing nvidia-driver-570-open from PPA..."
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update
sudo apt install -y nvidia-driver-570-open

# Install Docker
echo "[7/9] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Ollama
echo "[8/9] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat <<OLLAMACONF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
OLLAMACONF
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Install Tailscale
echo "[9/9] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "========================================="
echo "  DONE. REBOOT NOW:"
echo ""
echo "  sudo reboot"
echo ""
echo "  Then log in and run:"
echo ""
echo "  nvidia-smi"
echo "  sudo tailscale up"
echo "  tailscale ip"
echo "  ollama pull nomic-embed-text"
echo "  ollama pull qwen2.5:7b"
echo "========================================="
