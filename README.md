# Momo Store aka Dumpling House No. 2

<img width="900" alt="image" src="frontend/public/example.png">

A full-stack "dumpling shop" demo: Vue 3 SPA (frontend) + Go API (backend).

This repository is a capstone-style learning project focused on building the full delivery path for a small production-like service: local development, container images, CI/CD, cloud infrastructure, Kubernetes, and GitOps-based deployment.

## Repository layout

```
.
├── backend/            # Go API (port 8081)
│   ├── Dockerfile      # multi-stage, distroless runtime
│   └── Taskfile.yml    # backend tasks
├── frontend/           # Vue 3 SPA (port 8080)
│   ├── Dockerfile      # multi-stage, nginx runtime
│   ├── nginx.conf      # SPA routing + /healthz
│   └── Taskfile.yml    # frontend tasks
├── terraform/          # Yandex Cloud infrastructure (IaC)
│   ├── bootstrap/      # one-off: tf-admin SA + S3 bucket for tfstate
│   ├── infra/          # VPC, K8s cluster, node group
│   └── Taskfile.yml    # facade Taskfile, includes both modules
├── deploy/             # Kubernetes manifests (Helm charts)
│   ├── charts/         # namespaces, backend, frontend, ingress
│   ├── envs/           # per-environment values (staging, production, addons)
│   └── Taskfile.yml    # k8s:* tasks (deploy, status, addons)
├── .github/workflows/  # CI (ci.yml) + release pipeline (release.yml)
├── docker-compose.yml  # local development for both services
└── Taskfile.yml        # root Taskfile, includes backend, frontend, terraform, deploy
```

## Requirements

- [Docker](https://docs.docker.com/get-docker/) ≥ 24 with the `docker compose` plugin
- [Task](https://taskfile.dev/installation/) ≥ 3 — `brew install go-task` (macOS) or `go install github.com/go-task/task/v3/cmd/task@latest`

Optionally, for running without Docker:

- Go ≥ 1.26
- Node.js ≥ 20

## Quick start

```bash
task up
```

This builds the backend image, starts a hot-reloading frontend dev server on top of `node:20-alpine`, and exposes:

- Frontend → http://localhost:8080
- Backend → http://localhost:8081 (`/health`, `/metrics`, `/products`, ...)

Stop and remove the stack:

```bash
task down
```

## Available tasks

```bash
task              # list all tasks
task --list-all
```

Most useful ones:

| Task                              | Description                                                                      |
|-----------------------------------|----------------------------------------------------------------------------------|
| `task up`                         | Bring the full stack up via docker compose                                       |
| `task down`                       | Tear it down                                                                     |
| `task logs`                       | Tail compose logs for all services (`SERVICE=backend task logs` to limit to one) |
| `task ps`                         | Show service status                                                              |
| `task build`                      | Rebuild compose images                                                           |
| `task test`                       | Run backend Go tests                                                             |
| `task docker:build`               | Build production images for both services                                        |
| `task back:run`                   | Run the backend natively (`go run`)                                              |
| `task back:test`                  | Backend tests                                                                    |
| `task back:docker:build`          | Build the backend production image                                               |
| `task back:docker:run`            | Run the backend production image                                                 |
| `task front:serve`                | Vue dev server (native)                                                          |
| `task front:build`                | Build the SPA into `frontend/dist`                                               |
| `task front:docker:build`         | Build the frontend production image                                              |
| `task front:docker:run`           | Run the frontend production image                                                |
| `task tf:bootstrap:apply`         | One-off: create tf-admin SA + S3 state bucket (run once)                         |
| `task tf:infra:plan`              | Show planned cluster changes                                                     |
| `task tf:infra:apply`             | Provision / update VPC + K8s cluster                                             |
| `task tf:infra:destroy`           | Tear down all infra (DANGER — deletes the cluster)                               |
| `task tf:kubeconfig`              | Merge cluster credentials into `~/.kube/config`                                  |
| `task k8s:addons:ingress:install` | Install / upgrade ingress-nginx controller                                       |
| `task k8s:namespaces:apply`       | Create application namespaces (`staging`, `production`)                          |
| `task k8s:staging:deploy`         | Deploy backend, frontend, ingress to staging                                     |
| `task k8s:production:deploy`      | Deploy backend, frontend, ingress to production                                  |
| `task k8s:status`                 | Show all helm releases and key cluster resources                                 |

## Production images

Both Dockerfiles are multi-stage and intended for publishing to a Container Registry.

- **backend**: `golang:1.26-alpine` → `gcr.io/distroless/static-debian12:nonroot`. Statically linked binary (`CGO_ENABLED=0`), runs as a non-root user, listens on `:8081`.
- **frontend**: `node:20-alpine` → `nginxinc/nginx-unprivileged:1.27-alpine`. Static assets from `dist/` are served from `/`. The API URL is inlined at build time via `--build-arg VUE_APP_API_URL` (default `/api`, expecting an Ingress that routes `/api/*` to the backend; docker-compose overrides it to `http://localhost:8081`).

Build with a custom tag and API URL:

```bash
TAG=v0.1.0 task back:docker:build
TAG=v0.1.0 API_URL=https://api.example.com task front:docker:build
```

Run the production images locally:

```bash
task back:docker:run     # http://localhost:8081
task front:docker:run    # http://localhost:8080
```

OCI image labels (`org.opencontainers.image.version`, `revision`, `created`) are populated automatically from `git describe`, `git rev-parse HEAD`, and the current UTC timestamp by the Taskfile. CI pipelines can override them via `--build-arg`.

## CI/CD

GitHub Actions workflows live in [`.github/workflows/`](.github/workflows/):

| Workflow                                       | Trigger                                 | What it does                                                                        |
|------------------------------------------------|-----------------------------------------|-------------------------------------------------------------------------------------|
| [`ci.yml`](.github/workflows/ci.yml)           | Pull request to `main`                  | Runs Go tests, builds both Docker images (no push), checks terraform fmt + validate |
| [`release.yml`](.github/workflows/release.yml) | Push to `main` and `release-*` branches | Builds and pushes images to Yandex Container Registry                               |

### Branching model

Modified trunk-based:

- **`main`**: single integration branch; always releasable. Every PR merged here triggers a build that pushes `:main` and `:main-<sha>` images to YCR. From there, `task k8s:staging:deploy` rolls them out to **staging** (a future ArgoCD step will do this automatically).
- **`release-YYMMDDHHMM`**: short-lived release branches cut from `main` for promoting to production. The trailing `YYMMDDHHMM` is just a UTC timestamp serving as the release version (no SemVer). Push to such a branch triggers a build, **pauses for manual approval** in the `production` GitHub environment, then pushes `:YYMMDDHHMM`, `:release-YYMMDDHHMM`, and `:release-YYMMDDHHMM-<sha>` images. The image tag in `deploy/envs/production/*-values.yaml` is then bumped and `task k8s:production:deploy` rolls it out to **production**.
- **Hotfix flow**: fix in `main` → cherry-pick into a fresh `release-YYMMDDHHMM` branch cut from the broken release.

### Image tag scheme

| Trigger                      | Tags pushed                                                        |
|------------------------------|--------------------------------------------------------------------|
| Push to `main`               | `:main`, `:main-<sha7>`                                            |
| Push to `release-2604301700` | `:release-2604301700`, `:release-2604301700-<sha7>`, `:2604301700` |
| Pull request                 | (built only, not pushed)                                           |

The bare timestamp tag (`:2604301700`) is the canonical release identifier; `deploy/envs/production/*-values.yaml` pins to this tag for production deploys.

### Required GitHub configuration

Once-off setup in the repository:

1. **Repository secrets** (Settings → Secrets and variables → Actions → New repository secret):
   - `YC_SA_JSON_KEY` — full JSON of the Yandex Cloud service account key with the `container-registry.images.pusher` role on the registry.
2. **Repository variables** (same screen, Variables tab):
   - `YC_REGISTRY_ID` — the registry ID (`crp...`).
3. **Environments** (Settings → Environments → New environment):
   - `staging` — no protection rules. Used by `main` builds.
   - `production` — set "Required reviewers" to yourself / team. Used by `release-*` builds; the workflow waits for an approval click before pushing images.

### Cutting a release

```bash
git checkout main && git pull
git checkout -b release-$(date -u +%y%m%d%H%M)
git push -u origin HEAD
```

The push triggers `release.yml`. In the GitHub UI under Actions you'll see the run paused on "Waiting for review" — approve it, and images land in YCR within a couple of minutes.

## Infrastructure

All Yandex Cloud infrastructure is defined in [`terraform/`](terraform/) and split into two stages.

```
terraform/
├── bootstrap/   # one-off: tf-admin SA, HMAC keys, S3 bucket for tfstate
└── infra/       # everything else: VPC, K8s cluster, node group
```

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.9
- [yc CLI](https://yandex.cloud/en/docs/cli/quickstart) authenticated against your cloud (`yc init`)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### One-off bootstrap

```bash
# Use a short-lived IAM token of your user account for the bootstrap apply.
export YC_TOKEN=$(yc iam create-token)

task tf:bootstrap:init
task tf:bootstrap:apply

# Save the JSON key for tf-admin SA, the infra step authenticates with it.
mkdir -p ~/.config/momo-store
terraform -chdir=terraform/bootstrap output -raw tf_admin_key_json \
  > ~/.config/momo-store/tf-admin-key.json
chmod 600 ~/.config/momo-store/tf-admin-key.json

# Capture HMAC keys + bucket name for the s3 backend.
BUCKET=$(terraform -chdir=terraform/bootstrap output -raw tf_state_bucket)
echo "bucket = \"$BUCKET\"" > terraform/infra/backend.hcl

export AWS_ACCESS_KEY_ID=$(terraform -chdir=terraform/bootstrap output -raw tf_admin_access_key)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=terraform/bootstrap output -raw tf_admin_secret_key)
```

### Provisioning the cluster

```bash
# Same shell, AWS_* env vars must still be exported
task tf:infra:init       # downloads providers, configures s3 backend
task tf:infra:plan       # review what will be created
task tf:infra:apply      # creates VPC, master, nodes (~10 minutes)

task tf:kubeconfig       # merges cluster into ~/.kube/config
kubectl get nodes        # should show 2 Ready nodes
```

### What gets created

| Resource                                          | Purpose                                                                        |
|---------------------------------------------------|--------------------------------------------------------------------------------|
| `yandex_vpc_network.main` + `yandex_vpc_subnet.a` | One VPC, one /24 subnet in `ru-central1-a`                                     |
| `yandex_iam_service_account.k8s_cluster`          | Cluster SA with `k8s.clusters.agent`, `vpc.publicAdmin`, `load-balancer.admin` |
| `yandex_iam_service_account.k8s_nodes`            | Node SA to pull images from YCR (`images.puller`)                              |
| `yandex_kubernetes_cluster.main`                  | Zonal master, K8s 1.33, REGULAR channel, public IP                             |
| `yandex_kubernetes_node_group.main`               | 2 × `standard-v3` (2 vCPU / 4 GB), preemptible                                 |

Namespaces (`staging`, `production`) and everything that lives inside the cluster (apps, ingress controller, observability stack) are out of scope for terraform.

### Tearing it down

```bash
task tf:infra:destroy
# bootstrap still stays, the bucket holds historical state and costs ~nothing.
# Destroy bootstrap manually only if you really want to start from scratch:
#   cd terraform/bootstrap && terraform destroy
```

### Trade-offs to remember

- **Single AZ + zonal master.** Cheaper, but a YC zone outage takes the whole cluster down. Acceptable for a learning project; for real prod, switch the master to `regional` and spread the node group across zones.
- **Preemptible nodes.** Up to ~70% cheaper, but YC may evict each node once every 24h. Workloads need to tolerate restarts (which they should anyway).
- **`admin` role on `tf-admin`.** Convenient, broad. Tighten to a minimal role set once the project stabilizes.

## Kubernetes deployment

Everything inside the cluster is described as Helm charts in [`deploy/`](deploy/) and applied via `task k8s:*`.

```
deploy/
├── charts/
│   ├── namespaces/   # creates the staging + production namespaces
│   ├── backend/      # Go API: Deployment + Service + ServiceAccount
│   ├── frontend/     # Vue SPA on nginx: Deployment + Service + ServiceAccount
│   └── ingress/      # Ingress object: /api → backend, / → frontend
├── envs/
│   ├── staging/      # per-chart values overrides for staging
│   ├── production/   # per-chart values overrides for production
│   └── addons/       # values for upstream addon charts (ingress-nginx)
└── Taskfile.yml
```

Each environment runs three of our Helm releases (`<env>-backend`, `<env>-frontend`, `<env>-ingress`) in its own namespace, plus one cluster-level release for the ingress-nginx controller.

### First-time install

After the cluster is provisioned and `kubectl` points at it (`task tf:kubeconfig`):

```bash
task k8s:addons:ingress:install   # ingress-nginx controller + Yandex NLB
task k8s:namespaces:apply         # create staging + production namespaces
task k8s:staging:deploy           # backend, frontend, ingress in staging
task k8s:production:deploy        # same in production
task k8s:status                   # verify everything is Running
```

### Day-to-day deploys

Re-running `task k8s:<env>:deploy` is idempotent, it issues `helm upgrade --install` for each chart, which updates only what changed.

- **Staging** uses `image.tag: main` with `pullPolicy: Always`, so a fresh `:main` image gets picked up on the next deploy.
- **Production** pins explicit timestamp tags. Cutting a release: bump `image.tag` in `deploy/envs/production/{backend,frontend}-values.yaml` to the freshly published `:YYMMDDHHMM`, then `task k8s:production:deploy`.

### Tearing it down

To remove just the apps but keep the cluster:

```bash
helm uninstall staging-{ingress,frontend,backend} -n staging
helm uninstall production-{ingress,frontend,backend} -n production
helm uninstall ingress-nginx -n ingress-nginx
```

Or `task tf:infra:destroy` to delete the whole cluster, which takes everything inside with it.

## Running without Docker

Backend:

```bash
cd backend
go run ./cmd/api
go test -v ./...
```

Frontend:

```bash
cd frontend
npm install
VUE_APP_API_URL=http://localhost:8081 npm run serve
```
