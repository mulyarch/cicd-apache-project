
# 🚀 CI/CD Pipeline — Apache Hello World on AWS K8

A production-grade CI/CD pipeline demonstrating end-to-end automation from code commit to Kubernetes deployment on AWS. Built with Infrastructure as Code, containerization, configuration management, and automated testing.

## 📋 Architecture Overview

```
Developer → Git Push → GitHub Actions CI → ECR → GitHub Actions CD → EKS (Live)
```

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Feature    │     │   Develop    │     │     Main     │     │  Production  │
│   Branch     │────▶│   Branch     │────▶│    Branch    │────▶│    (EKS)     │
│              │ PR  │              │ PR  │              │ CD  │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
   CI: Lint/Test      CI: Push to ECR      CD: Deploy to K8s
```

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Infrastructure** | Terraform ~> 1.10 | VPC, EKS, ECR, IAM provisioning |
| **Container** | Docker (httpd:2.4-alpine) | Lightweight Apache web server |
| **Orchestration** | Amazon EKS (Kubernetes 1.35) | Container orchestration |
| **Registry** | Amazon ECR | Private Docker image storage |
| **CI/CD** | GitHub Actions | Automated pipelines |
| **Configuration** | Ansible + kubernetes.core | Deployment automation |
| **Security** | OIDC Federation, Trivy | Keyless auth, vulnerability scanning |
| **State** | S3 + Native Locking | Terraform state management |

## 🏗️ Infrastructure

All infrastructure is managed as code with Terraform:

- **VPC**: 3 AZs, public/private subnets, NAT Gateway
- **EKS Cluster**: Managed node groups (t3.medium), auto-scaling 1–3 nodes
- **ECR**: Private registry with lifecycle policies (retains last 10 images)
- **IAM**: OIDC-based authentication — zero long-lived credentials
- **S3 Backend**: Encrypted state with native S3 locking (no DynamoDB)

## 🔄 CI Pipeline

Triggered on: **Pull Requests** and **pushes to `develop`**

```yaml
validate → build-and-test → push-to-ecr
```

| Stage | Actions |
|-------|---------|
| **Validate** | Dockerfile lint (hadolint), Terraform validate/fmt, Ansible lint |
| **Build & Test** | Docker build, smoke tests (HTTP 200, content check), Trivy CVE scan |
| **Push to ECR** | Tag with commit SHA + `latest`, push to private registry |

## 🚢 CD Pipeline

Triggered on: **pushes to `main`**

```yaml
terraform-deploy → build-push → deploy → integration-tests
```

| Stage | Actions |
|-------|---------|
| **Terraform** | `terraform apply` — ensures infrastructure matches desired state |
| **Build & Push** | Production image tagged with SHA + `prod-latest` |
| **Deploy** | Rolling update to EKS (zero-downtime), 2 replicas |
| **Integration Tests** | Validates live endpoint (HTTP 200, content, pod count) |

## 🔐 Security Highlights

- **No AWS Access Keys** — GitHub OIDC federation provides short-lived credentials
- **Scoped IAM Role** — Only this specific repo can assume the deployment role
- **Trivy Scanning** — Blocks images with CRITICAL/HIGH vulnerabilities
- **ECR Scan on Push** — AWS-native vulnerability detection
- **Private Subnets** — EKS worker nodes are not directly internet-accessible
- **Rolling Updates** — Zero-downtime deployments (maxSurge: 1, maxUnavailable: 0)

## 📁 Project Structure

```
├── app/
│   ├── index.html              # Application source
│   └── Dockerfile              # Container definition
├── terraform/
│   ├── backend.tf              # S3 state configuration
│   ├── providers.tf            # Provider versions
│   ├── variables.tf            # Input variables
│   ├── main.tf                 # VPC, ECR, EKS
│   ├── github-oidc.tf          # OIDC + IAM role + policies
│   ├── outputs.tf              # Output values
│   └── environments/
│       ├── dev/terraform.tfvars
│       └── prod/terraform.tfvars
├── ansible/
│   ├── ansible.cfg             # Ansible configuration
│   ├── deploy-app.yml          # Main deployment playbook
│   └── roles/k8s-deploy/
│       ├── tasks/main.yml      # Deployment tasks
│       ├── templates/          # K8s manifests (Jinja2)
│       └── vars/main.yml       # Role variables
├── tests/
│   ├── test_docker.sh          # Docker smoke tests
│   └── test_integration.sh     # Live endpoint tests
├── .github/workflows/
│   ├── ci.yml                  # CI pipeline definition
│   └── cd.yml                  # CD pipeline definition
└── .gitignore
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.10
- Docker
- kubectl
- GitHub CLI (`gh`)

### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Set Up GitHub Secret

```bash
# Get the role ARN
terraform output github_actions_role_arn

# Add to GitHub (Settings → Secrets → Actions → AWS_ROLE_ARN)
```

### Development Workflow

```bash
# Create feature branch
git checkout develop && git pull origin develop
git checkout -b feature/my-change

# Make changes, commit, push
git add . && git commit -m "feat: my change"
git push origin feature/my-change

# Create PR, watch CI, merge — all from terminal
gh pr create --base develop --title "feat: my change" --body "Description"
gh run watch
gh pr merge --merge

# Deploy to production
gh pr create --base main --head develop --title "Deploy" --body "Release"
gh pr merge --merge
gh run watch
```

## 📊 Deployment Strategy

- **Rolling Update**: New pods are created before old ones are terminated
- **Health Checks**: Liveness and readiness probes ensure traffic only routes to healthy pods
- **Replicas**: 2 pods minimum for high availability
- **Rollback**: Kubernetes automatically rolls back failed deployments

## 🧪 Testing Strategy

| Level | Tool | What It Tests |
|-------|------|---------------|
| **Lint** | hadolint, terraform fmt, ansible-lint | Code quality & standards |
| **Security** | Trivy | Known CVEs in container images |
| **Smoke** | Bash/curl | Container builds and responds correctly |
| **Integration** | Bash/curl/kubectl | Live endpoint, pod health, LB connectivity |

## 📈 Future Enhancements

- [ ] Add Prometheus/Grafana monitoring
- [ ] Implement canary deployments
- [ ] Add Slack notifications on deploy success/failure
- [ ] Multi-environment (dev/staging/prod) with GitHub Environments
- [ ] Add Helm charts for more complex deployments
- [ ] Implement GitOps with ArgoCD

## 🧰 Key Decisions & Trade-offs

| Decision | Rationale |
|----------|-----------|
| OIDC over Access Keys | Security best practice — no credential rotation needed |
| S3 Native Locking over DynamoDB | Simpler, fewer resources, supported since Terraform 1.10 |
| NLB over ALB | Layer 4, lower latency, simpler for this use case |
| Single NAT Gateway | Cost optimization for learning environment |
| kubectl over Ansible in CD | More reliable in ephemeral CI runners |

---

*Built as a hands-on learning project demonstrating production CI/CD practices on AWS.*
