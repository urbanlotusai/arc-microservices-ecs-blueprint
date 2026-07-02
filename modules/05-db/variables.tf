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
  description = "S3 bucket name for Terraform state (used to read 02-network and 01-kms remote state)"
  type        = string
}

variable "engine" {
  description = "Aurora engine: aurora-postgresql or aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora engine version."
  type        = string
  default     = "15.4"
}

variable "username" {
  description = "Master username for the Aurora cluster."
  type        = string
  default     = "dbadmin"
}

variable "instance_class" {
  description = "Aurora instance class."
  type        = string
  default     = "db.r6g.large"
}

variable "backup_retention_period" {
  description = "Aurora backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the Aurora cluster."
  type        = bool
  default     = false
}
