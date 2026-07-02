# =============================================================================
# Module: 03-security-group
# =============================================================================
# Provisions the security group shared by ECS tasks, Aurora, and ElastiCache.
# State file: modules/03-security-group/terraform.tfstate
# Depends on: 02-network (vpc_id)
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

# -----------------------------------------------------------------------------
# Security Group Module
# -----------------------------------------------------------------------------

module "security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.5"

  name        = "${var.namespace}-${var.environment}-platform"
  description = "Security group for ECS tasks, Aurora, and ElastiCache"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "ECS container port from within VPC"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "PostgreSQL from within VPC"
    },
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Redis from within VPC"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.tags
}
