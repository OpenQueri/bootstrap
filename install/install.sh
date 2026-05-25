#!/bin/bash

set -e

echo "=== 1. SYSTEM UPDATE ==="
sudo apt update && sudo apt upgrade -y


echo "=== 2. BASIC TOOLS ==="
sudo apt install -y git curl


echo "=== 3. CHECK / INSTALL DOCKER ==="
if ! command -v docker &> /dev/null
then
    echo "Docker not found → installing"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
else
    echo "Docker already installed"
fi


echo "=== 4. CHECK / INSTALL NGINX ==="
if ! command -v nginx &> /dev/null
then
    echo "NGINX not found → installing"
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
else
    echo "NGINX already installed"
fi


echo "=== DONE ==="