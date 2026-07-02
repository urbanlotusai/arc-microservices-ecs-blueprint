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
  description = "S3 bucket name for Terraform state (used to read 02-network, 03-security-group, and 01-kms remote state)"
  type        = string
}

variable "node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.medium"
}

variable "num_cache_nodes" {
  description = "Number of ElastiCache Redis nodes."
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable Multi-AZ automatic failover (requires num_cache_nodes >= 2)."
  type        = bool
  default     = true
}
