#!/bin/bash
# 5090 GPU Box Setup — FOR ARCH LINUX
# Run AFTER archinstall finishes and you're logged in
# Usage: bash setup-5090.sh

echo "========================================="
echo "  5090 GPU Box — Arch Linux"
echo "========================================="

# Update system
echo "[1/6] Updating system..."
sudo pacman -Syu --noconfirm

# Install NVIDIA open driver (required for RTX 5090)
echo "[2/6] Installing nvidia-open driver..."
sudo pacman -S --noconfirm nvidia-open nvidia-utils nvidia-settings

# Install essentials
echo "[3/6] Installing essentials..."
sudo pacman -S --noconfirm base-devel git wget curl openssh docker firefox

# Enable SSH
sudo systemctl enable --now sshd

# Enable Docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Install Ollama
echo "[4/6] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat <<OLLAMACONF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
OLLAMACONF
sudo systemctl daemon-reload
sudo systemctl enable --now ollama

# Install Tailscale
echo "[5/6] Installing Tailscale..."
sudo pacman -S --noconfirm tailscale
sudo systemctl enable --now tailscaled

# Install desktop (KDE Plasma — lightweight, modern)
echo "[6/6] Installing desktop..."
sudo pacman -S --noconfirm plasma-meta sddm konsole dolphin
sudo systemctl enable sddm

echo ""
echo "========================================="
echo "  DONE. Run:"
echo ""
echo "  sudo reboot"
echo ""
echo "  After reboot you'll have a full desktop."
echo "  Open a terminal and run:"
echo ""
echo "  nvidia-smi"
echo "  sudo tailscale up"
echo "  tailscale ip"
echo "  ollama pull nomic-embed-text"
echo "  ollama pull qwen2.5:7b"
echo "========================================="
