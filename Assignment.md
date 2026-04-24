# Assignment

## Project Goal

Build a full release cycle for the **Momo Store** application — from a code commit to a running cloud service.

## What needs to be implemented?

- Organize the repository structure and choose a branching strategy: **Git Flow**, **Trunk-Based Development**, or **GitHub Flow**.
- Create optimized Docker images for the application components and publish them to a **Container Registry** with versioned tags.
- Define and deploy the following infrastructure in **Yandex Cloud** using **Terraform**:
  - a Kubernetes cluster;
  - S3 storage for the Terraform state;
  - S3 storage for serving static assets.
- Prepare Helm charts and deploy the application to the Kubernetes cluster.
- Define a **GitLab CI** pipeline that automatically builds, tests, and deploys the application.
- Build an observability system that collects metrics with **Prometheus** and visualizes key indicators in **Grafana**, using either **R.E.D. metrics** or **Golden Signals**.

## Documentation Requirements

High-quality documentation is an important part of engineering work. Your `README.md` should give any reader a complete understanding of the project.

Describe the architecture of your solution, the selected branching strategy, and the versioning approach. Then provide step-by-step instructions for deploying the required infrastructure first, followed by the application itself.

## Self-Review Checklist

Before submitting your work, go through the checklist below.

- The application is accessible from the internet by URL and/or IPv4 address.
- The CI/CD pipeline successfully passes all stages.
- Artifacts are versioned according to **SemVer**.
- Images are published to the Container Registry with versioned tags.
- The infrastructure is deployed, and its actual state fully matches the infrastructure described in code.
- The application runs in the Kubernetes cluster with health checks configured.
- The dashboard displays application metrics.
- The `README.md` contains deployment instructions.
