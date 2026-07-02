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
  description = "S3 bucket name for Terraform state (used to read 01-kms remote state)"
  type        = string
}

variable "visibility_timeout" {
  description = "SQS visibility timeout in seconds."
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "SQS message retention period in seconds (60-1209600)."
  type        = number
  default     = 345600
}

variable "dlq_max_receive_count" {
  description = "Number of delivery attempts before a message moves to the DLQ."
  type        = number
  default     = 3
}
