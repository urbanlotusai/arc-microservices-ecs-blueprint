variable "namespace" {
  description = "Organization or team namespace"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "arc-microservices-ecs-blueprint"
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state (used to read 02-network, 03-security-group, 05-db, 06-cache, 07-sqs, and 09-load-balancer remote state)"
  type        = string
}

variable "container_image" {
  description = "Container image URI for the ECS service (e.g. <account>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest)."
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of running ECS tasks."
  type        = number
  default     = 2
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Fargate task memory in MB."
  type        = string
  default     = "1024"
}

variable "db_port" {
  description = "Aurora port injected into the container environment as DB_PORT."
  type        = number
  default     = 5432
}
