# Deployment Reference

## Deploy

```bash
cp examples/general.tfvars terraform.tfvars
terraform init && terraform plan && terraform apply
```

## Push your first image

```bash
AWS_ACCOUNT=$(terraform output -raw kms_key_arn | cut -d: -f5)
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
docker build -t app .
docker tag app:latest $ECR_URL:v1.0.0
docker push $ECR_URL:v1.0.0
```

## Monitor

```bash
aws ecs list-tasks --cluster $(terraform output -raw ecs_cluster_name)
aws logs tail /ecs/$(terraform output -raw ecs_cluster_name)-api --follow
```

## Tear down

```bash
terraform destroy
```
