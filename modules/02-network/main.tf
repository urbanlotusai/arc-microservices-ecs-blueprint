# =============================================================================
# Module: 02-network
# =============================================================================
# Provisions the VPC and public/private subnets used by every other module
# in this blueprint.
# State file: modules/02-network/terraform.tfstate
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
# Network Module
# -----------------------------------------------------------------------------

module "network" {
  source  = "sourcefuse/arc-network/aws"
  version = "3.0.14"

  name        = "${var.namespace}-${var.environment}"
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.cidr_block

  tags = var.tags
}
