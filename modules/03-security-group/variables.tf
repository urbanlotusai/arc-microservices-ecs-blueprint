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
  description = "S3 bucket name for Terraform state (used to read 02-network remote state)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC (must match 02-network's cidr_block)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_port" {
  description = "Port the ECS container listens on."
  type        = number
  default     = 8080
}
