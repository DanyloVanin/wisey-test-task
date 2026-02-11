#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# check prerequisites
for cmd in docker minikube kubectl helm; do
  command -v "$cmd" &>/dev/null || { echo "Missing: $cmd"; exit 1; }
done
docker info &>/dev/null || { echo "Docker is not running"; exit 1; }

# start minikube (idempotent, skips if already running)
minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running" \
  || minikube start --cpus=4 --memory=7168 --driver=docker --addons=metrics-server

# helm repos
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo add vm https://victoriametrics.github.io/helm-charts/ 2>/dev/null || true
helm repo update

# install argocd
kubectl create namespace argocd 2>/dev/null || true
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values "$SCRIPT_DIR/argocd/install/values.yaml" \
  --wait --timeout 5m

kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=180s

# deploy apps via argocd (app of apps)
kubectl apply -f "$SCRIPT_DIR/argocd/root-app.yaml"

# wait for all apps to sync
echo "Waiting for ArgoCD apps to become healthy..."
for i in $(seq 1 40); do
  APPS=$(kubectl get applications -n argocd -o jsonpath='{range .items[*]}{.status.health.status}{"\n"}{end}' 2>/dev/null)
  TOTAL=$(echo "$APPS" | grep -c . || true)
  HEALTHY=$(echo "$APPS" | grep -c "Healthy" || true)

  if [ "$TOTAL" -ge 4 ] && [ "$HEALTHY" -eq "$TOTAL" ]; then
    echo "All $TOTAL apps healthy"
    break
  fi
  echo "  $HEALTHY/$TOTAL healthy (attempt $i/40)"
  sleep 15
done

# print access info
echo ""
echo "=== Access ==="
echo ""
ARGOCD_PW=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD:  kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "         http://localhost:8080  admin / $ARGOCD_PW"
echo ""
echo "Grafana: kubectl port-forward svc/victoria-metrics-grafana -n monitoring 3000:80"
echo "         http://localhost:3000  admin / admin"
echo ""
echo "spam2000: kubectl port-forward svc/spam2000 -n spam2000 3001:3000"
echo "          http://localhost:3001/metrics"
echo ""
kubectl get applications -n argocd
echo ""
kubectl get pods -A --field-selector=status.phase!=Succeeded
