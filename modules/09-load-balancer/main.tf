# =============================================================================
# Module: 09-load-balancer
# =============================================================================
# Provisions the Application Load Balancer fronting the ECS Fargate service.
# State file: modules/09-load-balancer/terraform.tfstate
# Depends on: 02-network (vpc_id, public subnets)
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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }
  tags = {
    Type = "public"
  }
}

# -----------------------------------------------------------------------------
# Load Balancer Module
# -----------------------------------------------------------------------------

module "alb" {
  source  = "sourcefuse/arc-load-balancer/aws"
  version = "0.0.3"

  name       = "${var.namespace}-${var.environment}-alb"
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.aws_subnets.public.ids

  security_group_name = "${var.namespace}-${var.environment}-alb-sg"

  load_balancer_config = {
    internal           = false
    load_balancer_type = "application"
    idle_timeout       = 60
  }

  # Wire WAF to ALB (08-waf remote state) once the WAF module has been applied:
  # web_acl_arn = data.terraform_remote_state.waf.outputs.arn

  alb_listener = {
    port     = 80
    protocol = "HTTP"
    # In production, use HTTPS and reference an ACM certificate:
    # port            = 443
    # protocol        = "HTTPS"
    # certificate_arn = data.aws_acm_certificate.this.arn
    default_action = {
      type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }

  tags = var.tags
}
