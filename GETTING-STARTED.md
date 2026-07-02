# Getting Started

See **[docs/INSTALL.md](docs/INSTALL.md)** to install Terraform and the AWS CLI.

1. Build and push your container image to ECR (after first apply):
   ```bash
   $(aws ecr get-login-password | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d/ -f1))
   docker build -t myapp:latest .
   docker tag myapp:latest $(terraform output -raw ecr_repository_url):latest
   docker push $(terraform output -raw ecr_repository_url):latest
   ```
2. Update `container_image` in `terraform.tfvars` to the ECR URI and re-apply.
3. Your service will be available at:
   ```bash
   terraform output alb_dns_name
   ```
