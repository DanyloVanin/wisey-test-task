#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# start minikube if not running
minikube status || minikube start --cpus=4 --memory=7168 --driver=docker --addons=metrics-server

# enable amd64 emulation on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
  minikube ssh "docker run --rm --privileged tonistiigi/binfmt --install amd64" >/dev/null 2>&1
fi

# helm repos
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

# install argocd
kubectl create namespace argocd 2>/dev/null || true
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values "$SCRIPT_DIR/argocd/install/values.yaml" \
  --wait --timeout 5m

# wait for argocd
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s

# apply root app
kubectl apply -f "$SCRIPT_DIR/argocd/root-app.yaml"

# print argocd password
echo ""
echo "ArgoCD password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "Port forwards:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "  kubectl port-forward svc/spam2000 -n spam2000 3001:3000"
