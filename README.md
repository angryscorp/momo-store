# Momo Store aka Dumpling House No. 2

<img width="900" alt="image" src="frontend/public/example.png">

A full-stack "dumpling shop" demo: Vue 3 SPA (frontend) + Go API (backend).

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
├── docker-compose.yml  # local development for both services
└── Taskfile.yml        # root Taskfile, includes back/* and front/*
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

| Task                      | Description                                                                      |
|---------------------------|----------------------------------------------------------------------------------|
| `task up`                 | Bring the full stack up via docker compose                                       |
| `task down`               | Tear it down                                                                     |
| `task logs`               | Tail compose logs for all services (`SERVICE=backend task logs` to limit to one) |
| `task ps`                 | Show service status                                                              |
| `task build`              | Rebuild compose images                                                           |
| `task test`               | Run backend Go tests                                                             |
| `task docker:build`       | Build production images for both services                                        |
| `task back:run`           | Run the backend natively (`go run`)                                              |
| `task back:test`          | Backend tests                                                                    |
| `task back:docker:build`  | Build the backend production image                                               |
| `task back:docker:run`    | Run the backend production image                                                 |
| `task front:serve`        | Vue dev server (native)                                                          |
| `task front:build`        | Build the SPA into `frontend/dist`                                               |
| `task front:docker:build` | Build the frontend production image                                              |
| `task front:docker:run`   | Run the frontend production image                                                |

## Production images

Both Dockerfiles are multi-stage and intended for publishing to a Container Registry.

- **backend**: `golang:1.26-alpine` → `gcr.io/distroless/static-debian12:nonroot`. Statically linked binary (`CGO_ENABLED=0`), runs as a non-root user, listens on `:8081`.
- **frontend**: `node:20-alpine` → `nginxinc/nginx-unprivileged:1.27-alpine`. Static assets from `dist/` are served under the `/momo-store/` path (see [`frontend/vue.config.js`](frontend/vue.config.js)). The API URL is inlined at build time via `--build-arg VUE_APP_API_URL`.

Build with a custom tag and API URL:

```bash
TAG=v0.1.0 task back:docker:build
TAG=v0.1.0 API_URL=https://api.example.com task front:docker:build
```

Run the production images locally:

```bash
task back:docker:run     # http://localhost:8081
task front:docker:run    # http://localhost:8080/momo-store/
```

OCI image labels (`org.opencontainers.image.version`, `revision`, `created`) are populated automatically from `git describe`, `git rev-parse HEAD`, and the current UTC timestamp by the Taskfile. CI pipelines can override them via `--build-arg`.

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
