# Sample App

A **zero-dependency Node.js HTTP service** that proves the microservices ECS stack works end-to-end with no code of your own. This is the exact image referenced by `var.container_image` in the ECS task definition (`module.ecs`).

```
ALB → Target Group → Fargate task (this container) → Aurora / Redis / SQS
```

Replace `index.js` with your real service whenever you are ready.

---

## What it returns

`GET /` → JSON welcome payload including the wired `DB_HOST`, `REDIS_HOST`, and `SQS_QUEUE` env vars (injected by the task definition).
`GET /health` → `{ "status": "ok" }`.

## Test locally

```bash
cd sample-app
node index.js          # starts on :8080
curl http://localhost:8080/health
```

## Build and push to ECR

This blueprint has no ECR module of its own — bring your own ECR repo (or reuse one from another ARC blueprint):

```bash
ECR_URL=<your-account-id>.dkr.ecr.<region>.amazonaws.com/microservices-ecs-sample
aws ecr create-repository --repository-name microservices-ecs-sample --image-tag-mutability IMMUTABLE --image-scanning-configuration scanOnPush=true
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

docker build -t $ECR_URL:latest sample-app/
docker push $ECR_URL:latest
```

## Deploy

Set `container_image = "$ECR_URL:latest"` in your `terraform.tfvars`, then:

```bash
terraform apply
```

Terraform updates the ECS task definition and the Fargate service performs a rolling deployment.

## Verify

```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl http://$ALB_DNS/health
curl http://$ALB_DNS/
```

## Order of operations

1. Build + push the sample image to an ECR repo you control
2. Set `container_image` in `terraform.tfvars`
3. `terraform apply` — creates VPC, Aurora, Redis, SQS, ALB, and the Fargate service running this image
4. Verify `/health` returns 200 through the ALB

---

Built by **[SourceFuse](https://www.sourcefuse.com)**.
