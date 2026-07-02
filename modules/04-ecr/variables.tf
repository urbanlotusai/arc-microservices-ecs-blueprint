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

variable "image_tag_mutability" {
  description = "ECR image tag mutability setting (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning on push."
  type        = bool
  default     = true
}

variable "max_tagged_image_count" {
  description = "Maximum number of tagged images to retain before the oldest are expired."
  type        = number
  default     = 20
}
