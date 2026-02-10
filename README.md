# Wisey SRE Test Task

GitOps infrastructure on Minikube: ArgoCD deploys spam2000, VictoriaMetrics monitoring stack, and Grafana dashboards. Everything is managed from Git.

## How it works

`bootstrap.sh` starts Minikube, installs ArgoCD via Helm, and applies a root Application CRD that manages everything else (App of Apps pattern):

- **spam2000** (ns: `spam2000`) — custom Helm chart, deployed from this repo
- **victoria-metrics** (ns: `monitoring`) — vm-k8s-stack external chart with our values
- **grafana-dashboards** (ns: `monitoring`) — cluster and app dashboards as ConfigMaps

Push a change to Git → ArgoCD syncs it to the cluster within ~3 minutes.

## Quick start

On Ubuntu (or any amd64 Linux with Docker, Minikube, kubectl, Helm):

```bash
# on a fresh Ubuntu box, install prerequisites first:
./setup-ubuntu.sh   # then re-login for docker group

./bootstrap.sh
```

The script is idempotent — safe to re-run.

## Accessing services

After bootstrap finishes, it prints credentials. Port-forward in separate terminals:

```bash
# ArgoCD — admin / <password from bootstrap output>
kubectl port-forward svc/argocd-server -n argocd 8080:80

# Grafana — admin / admin
kubectl port-forward svc/vm-stack-grafana -n monitoring 3000:80

# spam2000 app & metrics
kubectl port-forward svc/spam2000 -n spam2000 3001:3000
```

## GitOps demo

```bash
# change replica count in apps/spam2000/values.yaml → replicaCount: 2
git commit -am "scale spam2000 to 2 replicas" && git push
# ArgoCD picks it up within 3 minutes, or force sync:
kubectl get applications -n argocd -w
```

## Dashboards

**Cluster Overview** — CPU/memory usage, pod counts by namespace, pod status, resource requests vs limits, network I/O, disk usage.

**spam2000** — gauges over time (`random_gauge_1/2/3`, `name_gauge`), histogram distributions and percentiles (`ordered_histogram`, `random_histogram`), container resource usage. See [docs/spam2000-discovery.md](docs/spam2000-discovery.md) for details on the app's metrics.

The vm-k8s-stack also ships built-in dashboards for VictoriaMetrics, node-exporter, and kube-state-metrics.

## Repo structure

```
bootstrap.sh                        # entry point
setup-ubuntu.sh                     # install docker/minikube/kubectl/helm
apps/
  spam2000/                         # custom Helm chart (deployment, service, VMServiceScrape)
  victoria-metrics/values.yaml      # overrides for vm-k8s-stack
  grafana-dashboards/               # dashboard ConfigMaps (cluster + spam2000)
argocd/
  root-app.yaml                     # applied by bootstrap, manages everything below
  install/values.yaml               # ArgoCD Helm values
  applications/                     # child ArgoCD Application CRDs
docs/
  spam2000-discovery.md             # container investigation notes
```

## Cleanup

```bash
minikube delete
```
