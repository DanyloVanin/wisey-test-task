#!/usr/bin/env bash
# Install prerequisites for bootstrap.sh on a fresh Ubuntu (22.04/24.04)
set -euo pipefail

sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg

# docker
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  echo "NOTE: log out and back in for docker group to take effect"
fi

# kubectl
if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
fi

# minikube
if ! command -v minikube &>/dev/null; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
fi

# helm
if ! command -v helm &>/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo ""
echo "Installed versions:"
docker --version
kubectl version --client --short 2>/dev/null || kubectl version --client
minikube version --short
helm version --short
echo ""
echo "Ready. Run: ./bootstrap.sh"
