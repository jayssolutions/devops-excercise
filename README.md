# devops-excercise

A sample Node.js web app plus a full CI/CD, infrastructure-as-code, configuration-management, and monitoring pipeline, built for the DevOps take-home exercise (CI/CD, infrastructure automation, monitoring/logging, troubleshooting).

## Architecture

```
GitHub push to main
      │
      ▼
GitHub Actions (ci-cd.yml)
  ├─ build: lint + unit test the app
  └─ deploy:
        ├─ terraform apply  ──▶  VPC, ALB, 2x app EC2, Prometheus EC2, S3 state bucket
        ├─ build app.tar.gz
        ├─ build Ansible inventory from Terraform output
        └─ ansible-playbook  ──▶  installs Node.js, deploys app, starts systemd service
                                     │
                                     ▼
                        ALB ──▶ app instances (port 3000) ◀── Prometheus scrapes /metrics
```

## Repository layout

| Path | Purpose |
|---|---|
| [`app/`](app) | Express application (Task 1 subject, Task 3 metrics source) |
| [`terraform/`](terraform) | Infrastructure as code (Task 2.1) |
| [`ansible/`](ansible) | Configuration management / app deployment (Task 2.2) |
| [`scripts/build_inventory.sh`](scripts/build_inventory.sh) | Generates the Ansible inventory from live Terraform output |
| [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml) | CI (build/lint/test) + CD (provision, deploy, smoke test) |
| [`.github/workflows/terraform-destroy.yml`](.github/workflows/terraform-destroy.yml) | Manual, confirmation-gated teardown of the infra |

## Application

Express app in [`app/src`](app/src):

| Route | Purpose |
|---|---|
| `GET /` | Basic service info |
| `GET /health` / `GET /ready` | Health/readiness checks (used by the ALB and Ansible's post-deploy smoke test) |
| `GET /metrics` | Prometheus metrics (`prom-client`, includes default Node.js process metrics) |
| `GET /error` | Returns a 500, for exercising error-rate alerting |

Run locally:

```bash
cd app
npm install
npm start        # http://localhost:3000
```

```bash
npm run lint      # eslint
npm test          # jest + supertest
```

## CI/CD

[`ci-cd.yml`](.github/workflows/ci-cd.yml) runs on every push/PR:

- **`build`** — installs dependencies, runs `eslint`, runs the Jest suite.
- **`deploy`** (main branch only, after `build` passes) —
  1. Configures AWS credentials from secrets.
  2. Detects the runner's public IP and passes it as `admin_cidr`, so Terraform only opens SSH/Prometheus-UI access to the runner that's about to use it.
  3. `terraform init / validate / plan / apply` — provisions/updates the infrastructure.
  4. Packages the app into `app.tar.gz`.
  5. Builds the Ansible inventory from the live `terraform output instance_public_ips`.
  6. Waits for port 22 to be reachable on each instance, then runs the Ansible playbook to deploy the app.
  7. Smoke-tests `GET /health` on the deployed `application_url` before declaring success.

**Required GitHub Actions secrets:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `SSH_PUBLIC_KEY`, `SSH_PRIVATE_KEY`.

[`terraform-destroy.yml`](.github/workflows/terraform-destroy.yml) is a manual (`workflow_dispatch`) job that tears everything down — it requires typing `DESTROY` into the input box, as a guard against accidental teardown.

## Infrastructure (Terraform)

Modular config under [`terraform/`](terraform):

| Module | Creates |
|---|---|
| [`network`](terraform/modules/network) | VPC, 2 public subnets across AZs, internet gateway, public route table |
| [`alb`](terraform/modules/alb) | Application Load Balancer, target group (health check on `/health`), HTTP listener, ALB security group |
| [`compute`](terraform/modules/compute) | App EC2 instances (count configurable), key pair, security group (app port from ALB only, SSH from `admin_cidr` only) |
| [`monitoring`](terraform/modules/monitoring) | Prometheus EC2 instance, security group (UI/SSH from `admin_cidr` only) |
| [`s3`](terraform/modules/s3) | Versioned, encrypted, public-access-blocked S3 bucket used as the Terraform state backend |

State is stored remotely in S3 with native S3 locking (`use_lockfile = true`) — see [`backend.tf`](terraform/backend.tf).

To run manually:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in public_key, admin_cidr, etc.
terraform init
terraform plan
terraform apply
```

Key outputs ([`outputs.tf`](terraform/outputs.tf)): `application_url`, `instance_public_ips`, `prometheus_url`.

## Configuration Management (Ansible)

[`ansible/playbook.yml`](ansible/playbook.yml) targets the `[app]` group and:

1. Installs Node.js, npm, and tar via `dnf`.
2. Creates a dedicated, non-login `devops-excercise` system user.
3. Copies and extracts the app archive built by CI.
4. Installs production dependencies with `npm`.
5. Renders a systemd unit ([`templates/app.service.j2`](ansible/templates/app.service.j2)) and starts/enables the service, restarting it on config change.

The inventory isn't static — [`scripts/build_inventory.sh`](scripts/build_inventory.sh) regenerates `ansible/inventory.ini` from `terraform output instance_public_ips` on every CI run, so it always reflects the current instances.

To run manually against already-provisioned instances:

```bash
./scripts/build_inventory.sh
cd ansible
APP_ARCHIVE=../app.tar.gz ansible-playbook playbook.yml
```

## Monitoring and Logging

**Monitoring (done):** the [`monitoring`](terraform/modules/monitoring) module runs Prometheus on its own EC2 instance, scraping each app instance's `/metrics` on port 3000. Alert rules ([`templates/alerts.yml`](terraform/modules/monitoring/templates/alerts.yml)) cover the KPIs from the brief, using metrics the app already exposes via `prom-client` — no extra exporters needed:

- `HighErrorRate` — 5xx responses > 5% of traffic over 5m
- `HighProcessCPU` — process CPU > 80% over 5m
- `HighProcessMemory` — resident memory > 400MB
- `AppTargetDown` — a scrape target has been unreachable for 2m

Access the UI: `terraform output prometheus_url`, then open `http://<ip>:9090` (only reachable from the `admin_cidr` you deployed with) — check **Status → Targets** and **Alerts**.

**Logging (not yet done):** the app logs structured JSON to stdout, which systemd captures into `journald` on each instance, but there's no centralized log shipping/indexing (e.g. ELK) yet — logs currently have to be read instance-by-instance via `journalctl -u devops-excercise`.

## Known issues / assumptions 
- Prometheus alerts are visible in the UI only; no Alertmanager/notification channel (Slack, email, PagerDuty) is wired up yet.
- App instances sit in public subnets with public IPs (needed for the current SSH-based Ansible deploy); a private-subnet + bastion/SSM design would reduce exposure but adds setup complexity.
- Single environment (`dev`), single region (`us-east-1` by default).
- `ansible/inventory.ini` is generated at deploy time and isn't committed.

## End