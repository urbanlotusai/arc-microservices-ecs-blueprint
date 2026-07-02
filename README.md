<div align="center">

# ARC Microservices on ECS Blueprint

### Production microservices platform on ECS Fargate — with independent, per-module Terraform state

**A SourceFuse ARC Blueprint**

![Version](https://img.shields.io/badge/version-1.0.0-E8392A)
![License](https://img.shields.io/badge/license-Apache--2.0-1A1A2E)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-7B42BC)
![AWS Provider](https://img.shields.io/badge/aws--provider-%3E%3D5.0-FF9900)
![ARC Modules](https://img.shields.io/badge/ARC%20modules-10-E8392A)

</div>

---

## What is this?

A **ready-to-deploy Terraform blueprint** that wires a complete microservices platform on
AWS ECS Fargate using **10 [SourceFuse ARC](https://registry.terraform.io/namespaces/modules/sourcefuse) modules**.
`make bootstrap` + `make apply` gives you:

- **ECS Fargate cluster** with Container Insights enabled
- **ALB** (Application Load Balancer) fronted by a **WAF** Web ACL
- **Aurora PostgreSQL** (KMS-encrypted, longer backup retention + deletion protection on strict profiles)
- **ElastiCache Redis** (encrypted in-transit + at-rest)
- **SQS** inter-service queue with built-in DLQ
- **ECR** container registry (immutable tags, scan-on-push)
- A single **KMS CMK** encrypting everything

No hand-wiring of VPCs, IAM roles, ALB target groups, or WAF scopes. The hard, error-prone parts are already solved and pinned.

---

## Why use this blueprint?

| Advantage | What it means for you |
|---|---|
| **Minutes, not days** | A secured ECS microservices stack normally takes days of Terraform wiring — this deploys in one command. |
| **Secure by default** | Single KMS CMK encrypts Aurora, Redis, and SQS. ECR images scanned on push. WAF rate-limits all incoming traffic. |
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci` profiles activate longer Aurora backup retention, deletion protection, and tighter WAF rate limits. |
| **Proven building blocks** | Every resource comes from a published, versioned SourceFuse ARC module. Upgrades are a version bump. |
| **Serverless scaling** | Fargate scales tasks without managing nodes. Pay-per-vCPU-second, not per idle EC2 instance. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |
| **Beginner-friendly** | One `Makefile`, per-module compliance-profile tfvars, and step-by-step docs for macOS, Linux, and Windows. |

---

## Architecture

```
  Internet
      │
  ┌──────────────────────────────┐
  │  ALB  ←→  WAF (REGIONAL)    │
  └──────────────────────────────┘
      │
  ECS Fargate (private subnets)
  ├── Service A (container)
  ├── Service B (container)       ECR
  └── Service C (container)  ←── (container images)
       │          │          │
  Aurora DB    Redis       SQS Queue
  (KMS enc.)  (KMS enc.)  (+ DLQ)

  └── KMS CMK ── Aurora · Redis · SQS · ECR
```

---

## The 10 ARC modules

| Module | Version | Role |
|---|---|---|
| [arc-kms](https://registry.terraform.io/modules/sourcefuse/arc-kms/aws) | 1.0.11 | Customer Managed Key — root of the encryption trust chain |
| [arc-network](https://registry.terraform.io/modules/sourcefuse/arc-network/aws) | 3.0.14 | VPC + public/private subnets |
| [arc-security-group](https://registry.terraform.io/modules/sourcefuse/arc-security-group/aws) | 0.0.5 | DB, Redis, and service access control |
| [arc-ecr](https://registry.terraform.io/modules/sourcefuse/arc-ecr/aws) | 0.0.4 | Container registry (immutable, scan-on-push) |
| [arc-db](https://registry.terraform.io/modules/sourcefuse/arc-db/aws) | 4.0.4 | Aurora PostgreSQL cluster |
| [arc-cache](https://registry.terraform.io/modules/sourcefuse/arc-cache/aws) | 0.0.7 | ElastiCache Redis (encrypted at rest + in transit) |
| [arc-sqs](https://registry.terraform.io/modules/sourcefuse/arc-sqs/aws) | 0.0.3 | Inter-service queue + DLQ |
| [arc-waf](https://registry.terraform.io/modules/sourcefuse/arc-waf/aws) | 1.0.6 | REGIONAL Web ACL — attached to ALB |
| [arc-load-balancer](https://registry.terraform.io/modules/sourcefuse/arc-load-balancer/aws) | 0.0.3 | Application Load Balancer |
| [arc-ecs](https://registry.terraform.io/modules/sourcefuse/arc-ecs/aws) | 2.0.2 | ECS Fargate cluster + service definition |

---

## Quick start

### 1. Prerequisites

- **Terraform** `>= 1.3` ([install guide](docs/INSTALL.md))
- **AWS credentials** configured (`aws configure`)
- **A container image** pushed to ECR (or use `nginx:latest` for an initial smoke test)

### 2. Clone

```bash
git clone https://github.com/urbanlotusai/arc-microservices-ecs-blueprint.git
cd arc-microservices-ecs-blueprint
```

This blueprint uses **independent per-module Terraform state** — there is no root `main.tf`. Each `modules/NN-name/` is applied on its own, with cross-module values (like the VPC ID, KMS key ARN, and Aurora/Redis/SQS/ALB endpoints) resolved via `terraform_remote_state` data sources rather than a parent module.

### 3. Bootstrap the state backend (once per environment)

```bash
make bootstrap ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

Creates the S3 state bucket + DynamoDB lock table every module's backend uses.

### 4. Deploy all modules

```bash
make apply ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

This runs `terraform init` + `apply` across `modules/01-kms` through `modules/10-ecs` in dependency order. The `container_image` variable (default `nginx:latest`) can be overridden — either edit `modules/10-ecs/tfvars/general.tfvars` or pass a `-var` override — once you have a real image pushed to ECR (see Step 5).

### Deploy a single module with a compliance profile

```bash
./scripts/apply-module.sh 10-ecs dev us-east-1 hipaa
```

Copies `modules/10-ecs/tfvars/hipaa.tfvars` → `terraform.tfvars` for that module, then inits/plans/applies it alone.

| Step | With `make` (all modules) | Single module |
|---|---|---|
| Validate | `make validate` | `cd modules/<NN-name> && terraform validate` |
| Preview | `make plan` | `./scripts/apply-module.sh <name> <env> <region> <profile>` then inspect the plan |
| Deploy | `make apply` | `./scripts/apply-module.sh <name> <env> <region> <profile>` |

### 5. Push your container image to ECR

```bash
cd modules/04-ecr
ECR_URL=$(terraform output -raw repository_url)
cd ../..

aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker build -t $ECR_URL:latest sample-app/
docker push $ECR_URL:latest
```

Or run `make build-sample REGION=us-east-1`. Then re-apply `modules/10-ecs` with the new `container_image` to roll the service.

### 6. Verify the service

```bash
cd modules/09-load-balancer
ALB_DNS=$(terraform output -raw dns_name)
cd ../..

curl http://$ALB_DNS/health
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 7-day Aurora backup retention, WAF rate limit 5000 |
| `hipaa` | Aurora backup retention 35 days + deletion protection, WAF rate limit 2000, Redis automatic failover forced on |
| `pci` | Aurora backup retention 35 days + deletion protection, WAF rate limit 1000, Redis automatic failover forced on |

Apply a profile to any module with `./scripts/apply-module.sh <module> <env> <region> <profile>`.

---

## Key outputs

There is no root output aggregator — each module exposes its own outputs:

```bash
(cd modules/09-load-balancer && terraform output dns_name)          # ALB DNS — point your domain here
(cd modules/04-ecr && terraform output repository_url)              # push container images here
(cd modules/05-db && terraform output cluster_endpoint)              # Aurora writer endpoint
(cd modules/06-cache && terraform output cluster_address)            # ElastiCache primary endpoint
(cd modules/07-sqs && terraform output queue_url)                    # inter-service queue
(cd modules/07-sqs && terraform output dead_letter_queue_url)        # dead-letter queue
(cd modules/08-waf && terraform output arn)                          # WAF Web ACL ARN
(cd modules/01-kms && terraform output key_arn)                      # CMK
(cd modules/02-network && terraform output vpc_id)                   # VPC ID
```

---

## Project structure

```
arc-microservices-ecs-blueprint/
├── bootstrap/                 # creates the S3 + DynamoDB state backend (apply first)
│   ├── main.tf · variables.tf · outputs.tf
├── modules/                   # each folder is an independent Terraform root
│   ├── 01-kms/
│   │   ├── config.hcl         # static backend key
│   │   ├── main.tf            # own backend "s3" {}, own provider, own module block
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── tfvars/{general,hipaa,pci}.tfvars
│   ├── 02-network/
│   ├── 03-security-group/
│   ├── 04-ecr/
│   ├── 05-db/
│   ├── 06-cache/
│   ├── 07-sqs/
│   ├── 08-waf/
│   ├── 09-load-balancer/
│   └── 10-ecs/
├── scripts/
│   └── apply-module.sh        # apply one module with a chosen compliance profile
├── Makefile                   # bootstrap / init / plan / apply / validate / fmt / build-sample
├── .terraform-version         # tfenv pin (1.9.8)
├── sample-app/                # containerized API proving the ECS stack end-to-end
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment + ECR push + rollback
├── GETTING-STARTED.md        # beginner walkthrough
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough for first-timers
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform & AWS CLI on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, ECR push, service validation, rollback
- **`modules/*/tfvars/{general,hipaa,pci}.tfvars`** — per-module compliance-profile example files

---

## Important notes

- **WAF scope is REGIONAL** — this blueprint uses ALB (not CloudFront), so `web_acl_scope = "REGIONAL"`. Do not change it to `CLOUDFRONT`.
- **ECS tasks run in private subnets; ALB in public subnets** — do not change subnet assignments or the ALB health checks will fail.
- **Two-apply KMS pattern** — the ECS task execution role doesn't exist until after `10-ecs` is first applied. Narrow the KMS key policy to least-privilege afterward (see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)).
- **Container image must exist before ECS service deploys** — push an initial image to ECR (Step 5) before or immediately after the first `make apply` / `10-ecs` apply.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

<div align="center">

### Built by [SourceFuse](https://www.sourcefuse.com)

Part of the **ARC** (Accelerated Reference Cloud) blueprint family.
Explore all ARC modules on the [Terraform Registry](https://registry.terraform.io/namespaces/modules/sourcefuse).

</div>
