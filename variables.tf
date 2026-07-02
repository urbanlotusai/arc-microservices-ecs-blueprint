# ── Mandatory ─────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)."
  type        = string
}

variable "namespace" {
  description = "Project or team namespace used as a resource name prefix."
  type        = string
}

variable "db_password" {
  description = "Master password for the Aurora cluster. Use Secrets Manager in production."
  type        = string
  sensitive   = true
}

# ── Optional ──────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "compliance_profile" {
  description = "Compliance overlay profile."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa", "pci_dss"], var.compliance_profile)
    error_message = "compliance_profile must be general, hipaa, or pci_dss."
  }
}

variable "db_engine" {
  description = "Aurora engine: aurora-postgresql or aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "db_engine_version" {
  description = "Aurora engine version."
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "Aurora instance class."
  type        = string
  default     = "db.r6g.large"
}

variable "db_username" {
  description = "Master username for the Aurora cluster."
  type        = string
  default     = "dbadmin"
}

variable "cache_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.medium"
}

variable "cache_num_cache_nodes" {
  description = "Number of ElastiCache Redis nodes."
  type        = number
  default     = 2
}

variable "kms_deletion_window" {
  description = "Days before KMS key deletion takes effect (7–30)."
  type        = number
  default     = 30
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
