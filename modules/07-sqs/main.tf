# =============================================================================
# Module: 07-sqs
# =============================================================================
# Provisions the inter-service task queue with a built-in DLQ.
# State file: modules/07-sqs/terraform.tfstate
# Depends on: 01-kms (encryption key)
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/01-kms/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# SQS Module
# -----------------------------------------------------------------------------

module "sqs" {
  source  = "sourcefuse/arc-sqs/aws"
  version = "0.0.3"

  name = "${var.namespace}-${var.environment}-tasks"

  message_config = {
    visibility_timeout        = var.visibility_timeout
    retention_seconds         = var.message_retention_seconds
    receive_wait_time_seconds = 20
  }

  kms_config = {
    key_arn    = data.terraform_remote_state.kms.outputs.key_arn
    create_key = false
  }

  dlq_config = {
    enabled           = true
    name              = "${var.namespace}-${var.environment}-tasks-dlq"
    max_receive_count = var.dlq_max_receive_count
  }

  tags = var.tags
}
