# DevOps Portfolio - Cloud-Native Streaming Platform

Production-ready DevOps infrastructure for a microservices-based streaming application deployed on Kubernetes with GPU support, GitOps deployment, event-driven autoscaling, and comprehensive observability.

## Overview

This repository showcases my DevOps engineering work on a cloud-native streaming platform, demonstrating expertise in:

- **GitOps with ArgoCD** - Declarative, Git-based continuous deployment
- **CI/CD Pipelines** - Automated build and deployment with GitHub Actions
- **Container Orchestration** - Kubernetes (K3S) with multi-service architecture
- **Event-Driven Autoscaling** - KEDA with Prometheus-based scaling triggers
- **GPU Infrastructure** - NVIDIA GPU node setup and configuration
- **Observability** - Prometheus, Grafana, and Fluent Bit log aggregation
- **Infrastructure as Code** - Automated cluster setup and configuration scripts

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                   GitOps Flow                                           │
│                                                                                         │
│   Developer ──► Git Push ──► GitHub Repo ──► ArgoCD (Pull-based) ──► Kubernetes        │
│                                    │                                                    │
│                    GitHub Actions (Build & Push Images to ECR)                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                              Kubernetes Cluster (K3S)                                    │
│                                                                                          │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              ArgoCD (GitOps Controller)                          │   │
│  │  • Continuous sync from Git repository                                           │   │
│  │  • App-of-Apps pattern for multi-service management                              │   │
│  │  • ApplicationSet for multi-environment deployments                              │   │
│  │  • Self-healing (auto-revert manual changes)                                     │   │
│  └──────────────────────────────────────────────────────────────────────────────────┘   │
│                                         │                                                │
│                                         ▼                                                │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                      │
│  │   Frontend      │    │     API         │    │    Worker       │                      │
│  │   (React/Nginx) │    │   (NestJS)      │    │  (FFmpeg/Node)  │                      │
│  │   Port: 80      │    │   Port: 3010    │    │   Port: 3001    │                      │
│  └────────┬────────┘    └────────┬────────┘    └────────┬────────┘                      │
│           │                      │                      │                               │
│           └──────────────────────┼──────────────────────┘                               │
│                                  │                                                      │
│  ┌───────────────────────────────┼───────────────────────────────────────────────────┐  │
│  │                         Traefik Ingress                                           │  │
│  │              (TLS termination via Let's Encrypt)                                  │  │
│  └───────────────────────────────┴───────────────────────────────────────────────────┘  │
│                                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                              KEDA Autoscaling                                       ││
│  │  • Prometheus metrics (RPS, latency, active streams)                               ││
│  │  • CPU/Memory utilization triggers                                                 ││
│  │  • Conservative scale-down for long-running workloads                              ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                           Observability Stack                                       ││
│  │  • Prometheus (metrics collection)                                                 ││
│  │  • Grafana (visualization, dashboards)                                             ││
│  │  • Fluent Bit (log aggregation → CloudWatch)                                       ││
│  │  • DCGM Exporter (GPU metrics)                                                     ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
devops-portfolio/
├── argocd/
│   ├── applications/
│   │   ├── api-application.yaml        # ArgoCD Application for API
│   │   ├── worker-application.yaml     # ArgoCD Application for Worker
│   │   ├── frontend-application.yaml   # ArgoCD Application for Frontend
│   │   ├── services-application.yaml   # ArgoCD Application for Services
│   │   ├── ingress-application.yaml    # ArgoCD Application for Ingress
│   │   ├── keda-application.yaml       # ArgoCD Application for KEDA configs
│   │   └── root-application.yaml       # App-of-Apps + ApplicationSet
│   ├── appprojects/
│   │   └── streaming-platform-project.yaml  # ArgoCD AppProject with RBAC
│   └── setup/
│       ├── 01-install-argocd.sh        # ArgoCD installation script
│       ├── 02-configure-argocd.sh      # ArgoCD configuration script
│       └── argocd-ingress.yaml         # Ingress for ArgoCD UI
│
├── cicd/
│   └── github-actions/
│       ├── api-build-deploy.yml        # API service CI/CD pipeline
│       ├── worker-build-deploy.yml     # Worker service CI/CD pipeline
│       └── frontend-build-deploy.yml   # Frontend CI/CD pipeline
│
├── kubernetes/
│   ├── deployments/
│   │   ├── api-deployment.yaml         # API deployment with health checks
│   │   ├── worker-deployment.yaml      # Worker deployment with TCP probes
│   │   └── frontend-deployment.yaml    # Frontend deployment
│   ├── services/
│   │   ├── api-service.yaml            # ClusterIP service for API
│   │   ├── worker-service.yaml         # ClusterIP service for Worker
│   │   └── frontend-service.yaml       # ClusterIP service for Frontend
│   ├── ingress/
│   │   ├── api-ingress.yaml            # Traefik ingress with TLS
│   │   ├── worker-ingress.yaml         # Worker ingress with HTTPS redirect
│   │   └── frontend-ingress.yaml       # Frontend ingress
│   ├── secrets/
│   │   └── (templates - actual secrets not committed)
│   └── keda/
│       ├── api-scaledobject.yaml       # KEDA autoscaling for API
│       └── worker-scaledobject.yaml    # KEDA autoscaling for Worker
│
├── docker/
│   ├── Dockerfile.api                  # Multi-stage Dockerfile for API
│   ├── Dockerfile.worker               # Alpine-based Dockerfile for Worker
│   └── Dockerfile.frontend             # React build with Nginx
│
├── monitoring/
│   ├── prometheus/
│   │   └── (ServiceMonitor configs)
│   └── fluentbit/
│       ├── daemonset.yaml              # Fluent Bit DaemonSet
│       ├── configmap.yaml              # Log routing configuration
│       └── rbac.yaml                   # Service account and permissions
│
├── k3s-setup/
│   ├── 00-prerequisites.sh             # System deps + NVIDIA drivers
│   ├── 01-install-k3s.sh               # K3S installation with GPU support
│   ├── 02-install-ingress-certmanager.sh  # Nginx Ingress + cert-manager
│   ├── 03-install-monitoring.sh        # Prometheus + Grafana + DCGM
│   ├── 04-install-keda.sh              # KEDA operator installation
│   └── kubelet-config.yaml             # Optimized kubelet configuration
│
├── makefiles/
│   ├── Makefile.api                    # API build automation
│   ├── Makefile.worker                 # Worker build with registry caching
│   └── Makefile.frontend               # Frontend build automation
│
└── README.md
```

## Key Features

### 1. GitOps with ArgoCD

Declarative, Git-based continuous deployment following GitOps principles:

**App-of-Apps Pattern:**
- Root Application manages all child applications
- Single point of configuration for entire platform
- Hierarchical application management

**ApplicationSet for Multi-Environment:**
- Automatic application generation for dev/staging/prod
- Branch-based deployment (develop → dev, staging → staging, main → prod)
- Consistent configuration across environments

**Key Features:**
- **Automated Sync**: Continuous reconciliation with Git repository
- **Self-Healing**: Auto-revert manual cluster changes
- **Pruning**: Automatic cleanup of deleted resources
- **RBAC**: Fine-grained access control via AppProject

```yaml
# ArgoCD Application with automated sync
syncPolicy:
  automated:
    prune: true      # Delete resources not in Git
    selfHeal: true   # Revert manual changes
  syncOptions:
    - CreateNamespace=true
    - ApplyOutOfSyncOnly=true
  retry:
    limit: 5
    backoff:
      duration: 5s
      factor: 2
      maxDuration: 3m
```

**AppProject RBAC:**
```yaml
roles:
  - name: developer
    policies:
      - p, proj:streaming-platform:developer, applications, sync, *, allow
  - name: admin
    policies:
      - p, proj:streaming-platform:admin, applications, *, *, allow
```

**Sync Windows (Change Management):**
```yaml
syncWindows:
  # Allow syncs during business hours
  - kind: allow
    schedule: "0 8 * * 1-5"
    duration: 10h
  # Block production changes on weekends
  - kind: deny
    schedule: "0 0 * * 0,6"
    duration: 48h
    namespaces: [production]
```

### 2. CI/CD Pipelines (GitHub Actions)

Automated build and deployment pipelines for all services:

- **Trigger**: Push to `devops` branch or manual dispatch
- **Build**: Docker Buildx with multi-platform support (linux/amd64)
- **Registry**: AWS ECR with image tagging (latest + commit SHA)
- **Deploy**: kubectl apply with rollout status verification
- **Security**: Secrets managed via GitHub Environments

```yaml
# Example: Build and push with registry caching
- name: Build and Push API Image
  run: make push
  env:
    CACHE_MODE: registry  # Uses ECR-based build cache
```

### 3. Kubernetes Deployments

Production-ready deployment configurations with:

- **Rolling Updates**: Zero-downtime deployments with maxSurge/maxUnavailable
- **Health Checks**: HTTP liveness/readiness probes
- **Resource Limits**: CPU/Memory requests and limits
- **Node Affinity**: GPU/non-GPU node scheduling
- **Security**: Non-root users, fsGroup, imagePullSecrets

```yaml
# GPU-aware scheduling
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
            - key: gpu
              operator: DoesNotExist
```

### 4. KEDA Event-Driven Autoscaling

Intelligent autoscaling based on application metrics:

**API Scaling Triggers:**
- HTTP requests per second (threshold: 50 RPS)
- P95 response latency (threshold: 500ms)
- Active streams count (threshold: 10 per pod)
- CPU utilization fallback (80%)

**Worker Scaling Triggers:**
- Active streams per worker (threshold: 5)
- CPU utilization (60% - FFmpeg intensive)
- Memory utilization (70%)
- Conservative scale-down (10 min cooldown for long-running streams)

```yaml
# Conservative scaling behavior for workers
advanced:
  horizontalPodAutoscalerConfig:
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 600  # 10 min stabilization
        policies:
          - type: Pods
            value: 1
            periodSeconds: 300           # Scale down 1 pod per 5 min
```

### 5. GPU Infrastructure Setup

Complete GPU node setup for K3S:

- NVIDIA driver installation and verification
- NVIDIA Container Toolkit configuration
- Containerd runtime configuration for GPU support
- DCGM Exporter for GPU metrics monitoring
- Kubelet feature gates for DevicePlugins

```bash
# Configure NVIDIA runtime for K3S containerd
sudo nvidia-ctk runtime configure \
  --runtime=containerd \
  --config=/var/lib/rancher/k3s/agent/etc/containerd/config.toml
```

### 6. Observability Stack

**Prometheus + Grafana:**
- kube-prometheus-stack deployment
- Custom ServiceMonitors for application metrics
- NVIDIA DCGM Exporter for GPU metrics
- Pre-configured dashboards (DCGM: 12239, Pod metrics: 6417)

**Fluent Bit Log Aggregation:**
- DaemonSet deployment on all nodes
- Kubernetes metadata enrichment
- Namespace-based log routing (dev → separate log streams)
- CloudWatch Logs integration with 14-day retention
- Noise filtering (health checks excluded)

```
Log Routing:
  youtube-frontend-* → /k3s/dev/frontend
  youtube-stream-worker-* → /k3s/dev/worker
  youtubr-api-cpu-* → /k3s/dev/api
```

### 7. Docker Multi-Stage Builds

Optimized container images with:

- Multi-stage builds for minimal image size
- BuildKit cache mounting for faster builds
- Non-root user execution
- Health checks built into images
- dumb-init for proper signal handling

```dockerfile
# BuildKit cache for npm dependencies
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=optional
```

### 8. Build Automation (Makefiles)

Streamlined build process with:

- ECR authentication
- Docker Buildx with registry caching
- Multi-tag support (latest + commit SHA)
- One-command deployment (`make ship`)

```bash
# Full deployment pipeline
make ship  # login → build → push → deploy
```

## Technologies Used

| Category | Technologies |
|----------|-------------|
| **GitOps** | ArgoCD, ApplicationSet, App-of-Apps pattern |
| **Container Orchestration** | Kubernetes (K3S), containerd |
| **CI/CD** | GitHub Actions, Docker Buildx |
| **Container Registry** | AWS ECR |
| **Ingress** | Traefik, Nginx Ingress Controller |
| **TLS/Certificates** | cert-manager, Let's Encrypt |
| **Autoscaling** | KEDA, Prometheus |
| **Monitoring** | Prometheus, Grafana, DCGM Exporter |
| **Logging** | Fluent Bit, AWS CloudWatch Logs |
| **GPU Support** | NVIDIA Container Toolkit, GPU Operator |
| **Build Tools** | Make, Docker Buildx |

## Cloud Infrastructure

- **Cloud Provider**: AWS (eu-north-1 region)
- **Container Registry**: AWS ECR
- **Object Storage**: AWS S3
- **Log Storage**: AWS CloudWatch Logs
- **Server Specs**: 48 cores, 128GB RAM (optimized kubelet config)

## Security Considerations

- Non-root container execution
- Kubernetes Secrets for sensitive data
- RBAC with minimal required permissions
- TLS/HTTPS enforcement on all ingress
- Image pull secrets for private registry access
- Resource limits to prevent resource exhaustion
- ArgoCD AppProject role-based access control

## Getting Started

### Prerequisites

- Kubernetes cluster (K3S recommended)
- AWS CLI configured
- kubectl configured
- Helm 3.x
- Docker with Buildx
- ArgoCD CLI (optional)

### Installation Order

1. **Prerequisites**: `bash k3s-setup/00-prerequisites.sh`
2. **K3S Cluster**: `bash k3s-setup/01-install-k3s.sh`
3. **Ingress + TLS**: `bash k3s-setup/02-install-ingress-certmanager.sh`
4. **Monitoring**: `bash k3s-setup/03-install-monitoring.sh`
5. **KEDA**: `bash k3s-setup/04-install-keda.sh`
6. **ArgoCD**: `bash argocd/setup/01-install-argocd.sh`
7. **Configure ArgoCD**: `bash argocd/setup/02-configure-argocd.sh`

### Deploy with ArgoCD (GitOps)

```bash
# Install ArgoCD
bash argocd/setup/01-install-argocd.sh

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login (get password from install output)
argocd login localhost:8080 --username admin --password <password> --insecure

# Apply root application (deploys all services)
kubectl apply -f argocd/applications/root-application.yaml

# Or apply individual applications
kubectl apply -f argocd/appprojects/streaming-platform-project.yaml
kubectl apply -f argocd/applications/
```

### Deploy Manually (kubectl)

```bash
# Deploy all services
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/
kubectl apply -f kubernetes/keda/
```

## ArgoCD Dashboard

Access the ArgoCD UI to manage deployments:

```bash
# Port forward to access locally
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open in browser
open https://localhost:8080
```

**ArgoCD UI Features:**
- Visual application topology
- Real-time sync status
- Diff view for changes
- Rollback to previous versions
- Resource health monitoring

## Author

DevOps Engineer with expertise in cloud-native infrastructure, Kubernetes, GitOps, and CI/CD automation.

## License

This project is for portfolio demonstration purposes.
