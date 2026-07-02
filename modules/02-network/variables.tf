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
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}
