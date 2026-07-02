<div align="center">

# ARC Microservices on ECS Blueprint

### Production microservices platform on ECS Fargate — in one `terraform apply`

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
One `terraform apply` gives you:

- **ECS Fargate cluster** with Container Insights enabled
- **ALB** (Application Load Balancer) fronted by a **WAF** Web ACL
- **Aurora PostgreSQL** (KMS-encrypted, PITR on strict profiles)
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
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci_dss` profiles activate Aurora PITR, deletion protection, and tighter WAF rate limits. |
| **Proven building blocks** | Every resource comes from a published, versioned SourceFuse ARC module. Upgrades are a version bump. |
| **Serverless scaling** | Fargate scales tasks without managing nodes. Pay-per-vCPU-second, not per idle EC2 instance. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |
| **Beginner-friendly** | One `Makefile`, copy-paste examples per profile, and step-by-step docs for macOS, Linux, and Windows. |

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
- **A container image** pushed to ECR (or use `nginx:latest` for initial smoke test)

### 2. Configure

```bash
git clone https://github.com/sourcefuse/arc-microservices-ecs-blueprint.git
cd arc-microservices-ecs-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the mandatory values in `terraform.tfvars`:

| Variable | Example |
|---|---|
| `environment` | `prod` |
| `namespace` | `myorg` |
| `db_password` | `YourSecureDBPassword` |
| `container_image` | `123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:v1.0.0` |

### 3. Deploy

| Step | With `make` | Raw Terraform (all OS) |
|---|---|---|
| Validate | `make validate` | `terraform init -backend=false && terraform validate` |
| Preview | `make plan` | `terraform plan` |
| Deploy | `make apply` | `terraform init && terraform apply` |

### 4. Push your container image to ECR

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)

aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 5. Verify the service

```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl http://$ALB_DNS/health
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 7-day Aurora PITR, WAF rate limit 5000 |
| `hipaa` | Aurora PITR 35 days + deletion protection, WAF rate limit 2000, ECS task concurrency cap |
| `pci_dss` | Aurora PITR 35 days + deletion protection, WAF rate limit 1000, Redis automatic failover |

---

## Key outputs

```bash
terraform output alb_dns_name            # ALB DNS — point your domain here
terraform output ecr_repository_url      # push container images here
terraform output db_cluster_endpoint     # Aurora writer endpoint
terraform output redis_endpoint          # ElastiCache primary endpoint
terraform output sqs_queue_url           # inter-service queue
terraform output sqs_dlq_url             # dead-letter queue
terraform output waf_arn                 # WAF Web ACL ARN
terraform output kms_key_arn             # CMK
terraform output vpc_id                  # VPC ID
```

---

## Project structure

```
arc-microservices-ecs-blueprint/
├── main.tf                   # 10 ARC module blocks, in dependency order
├── variables.tf              # all inputs with types & descriptions
├── locals.tf                 # naming, tags, compliance overlays
├── data.tf                   # caller identity, KMS policy, subnet lookups
├── outputs.tf                # ALB DNS, ECR URL, Aurora/Redis endpoints, queue URLs
├── version.tf                # Terraform + AWS provider pins
├── .terraform-version        # tfenv pin (1.9.8)
├── terraform.tfvars.example  # copy to terraform.tfvars
├── modules/                  # one numbered wrapper per ARC module
│   ├── 01-kms/
│   ├── 02-network/
│   ├── 03-security-group/
│   ├── 04-ecr/
│   ├── 05-db/
│   ├── 06-cache/
│   ├── 07-sqs/
│   ├── 08-waf/
│   ├── 09-load-balancer/
│   └── 10-ecs/
├── sample-app/                # containerized API proving the ECS stack end-to-end
├── examples/
│   ├── README.md
│   ├── general.tfvars
│   ├── hipaa.tfvars
│   └── pci_dss.tfvars
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment + ECR push + rollback
├── GETTING-STARTED.md        # beginner walkthrough
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · Makefile · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough for first-timers
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform & AWS CLI on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, ECR push, service validation, rollback
- **[examples/README.md](examples/README.md)** — compliance-profile example files

---

## Important notes

- **WAF scope is REGIONAL** — this blueprint uses ALB (not CloudFront), so `web_acl_scope = "REGIONAL"`. Do not change it to `CLOUDFRONT`.
- **ECS tasks run in private subnets; ALB in public subnets** — do not change subnet assignments or the ALB health checks will fail.
- **Two-apply KMS pattern** — the ECS task execution role doesn't exist until after the first apply. Narrow the KMS key policy to least-privilege afterward (see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)).
- **Container image must exist before ECS service deploys** — push an initial image to ECR before or immediately after the first `terraform apply`.

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
