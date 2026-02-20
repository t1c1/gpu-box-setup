#!/bin/bash
# 5090 GPU Box Setup — BULLETPROOF v3
# RTX 5090 needs open kernel modules built from source + driver 570.144
# Usage: bash setup-5090.sh

echo "========================================="
echo "  5090 GPU Box Setup v3"
echo "  Ubuntu 24.04 + RTX 5090"
echo "========================================="
echo ""
echo "  THIS WILL TAKE 15-20 MINUTES"
echo "  Go do something else."
echo ""
echo "========================================="

# Fix any broken dpkg state
echo "[1/8] Fixing package manager..."
sudo dpkg --configure -a
sudo apt-get install -f -y

# Nuke ALL nvidia packages and configs
echo "[2/8] Nuking all NVIDIA packages and configs..."
sudo apt-get remove --purge '^nvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge '^libnvidia-.*' -y 2>/dev/null
sudo apt-get remove --purge 'nvidia-*' -y 2>/dev/null
sudo apt-get remove --purge 'cuda*' -y 2>/dev/null
sudo dpkg --configure -a
sudo apt-get autoremove --purge -y
sudo apt-get autoclean
sudo find /etc -name '*nvidia*' -exec rm -rf {} + 2>/dev/null
sudo rm -rf /usr/local/cuda* 2>/dev/null

# Update system
echo "[3/8] Updating system..."
sudo apt update
sudo apt upgrade -y

# Install build tools
echo "[4/8] Installing build tools..."
sudo apt install -y build-essential dkms pkg-config libegl1 libglvnd-dev \
    linux-headers-$(uname -r) wget curl git openssh-server sshfs

# Build NVIDIA open kernel modules from source (required for RTX 5090)
echo "[5/8] Building NVIDIA open kernel modules (this takes a while)..."
cd /tmp
if [ -d open-gpu-kernel-modules ]; then
    rm -rf open-gpu-kernel-modules
fi
git clone https://github.com/NVIDIA/open-gpu-kernel-modules.git
cd open-gpu-kernel-modules
git checkout 570.144
make modules -j$(nproc)
sudo make modules_install -j$(nproc)
sudo update-initramfs -u

# Download and install NVIDIA driver 570.144 (skip kernel modules since we built them)
echo "[6/8] Installing NVIDIA driver 570.144..."
cd /tmp
if [ ! -f NVIDIA-Linux-x86_64-570.144.run ]; then
    wget https://us.download.nvidia.com/XFree86/Linux-x86_64/570.144/NVIDIA-Linux-x86_64-570.144.run
fi
chmod +x NVIDIA-Linux-x86_64-570.144.run
sudo sh NVIDIA-Linux-x86_64-570.144.run --silent --no-kernel-modules

# Install Docker
echo "[7/8] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Ollama + configure to listen on all interfaces
echo "[7/8] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat <<OLLAMACONF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
OLLAMACONF
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Install Tailscale
echo "[8/8] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "========================================="
echo "  DONE. Run these commands:"
echo "========================================="
echo ""
echo "  sudo reboot"
echo ""
echo "  (log back in after reboot, then:)"
echo ""
echo "  nvidia-smi"
echo "  sudo tailscale up"
echo "  tailscale ip"
echo "  ollama pull nomic-embed-text"
echo "  ollama pull qwen2.5:7b"
echo ""
echo "========================================="
