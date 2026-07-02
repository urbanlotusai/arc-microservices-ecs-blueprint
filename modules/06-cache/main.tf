# =============================================================================
# Module: 06-cache
# =============================================================================
# Provisions the ElastiCache Redis cluster used as the microservices
# platform's session store and caching layer.
# State file: modules/06-cache/terraform.tfstate
# Depends on: 02-network (vpc_id, private subnets),
#             03-security-group (security group id), 01-kms (encryption key)
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

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/02-network/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/03-security-group/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/01-kms/terraform.tfstate"
    region = var.region
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }
  tags = {
    Type = "private"
  }
}

# -----------------------------------------------------------------------------
# ElastiCache Module
# -----------------------------------------------------------------------------

module "cache" {
  source  = "sourcefuse/arc-cache/aws"
  version = "0.0.7"

  name               = "${var.namespace}-${var.environment}-redis"
  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [data.terraform_remote_state.security_group.outputs.id]

  node_type       = var.node_type
  num_cache_nodes = var.num_cache_nodes

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = data.terraform_remote_state.kms.outputs.key_arn

  automatic_failover_enabled = var.automatic_failover_enabled

  tags = var.tags
}
