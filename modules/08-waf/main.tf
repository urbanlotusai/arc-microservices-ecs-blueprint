# =============================================================================
# Module: 08-waf
# =============================================================================
# Provisions the REGIONAL Web ACL attached to the ALB, rate-limiting incoming
# traffic.
# State file: modules/08-waf/terraform.tfstate
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
# WAF Module
# -----------------------------------------------------------------------------

module "waf" {
  source  = "sourcefuse/arc-waf/aws"
  version = "1.0.6"

  web_acl_name           = "${var.namespace}-${var.environment}-alb-waf"
  web_acl_default_action = "ALLOW"
  web_acl_scope          = "REGIONAL"

  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.namespace}-${var.environment}-alb-waf"
    sampled_requests_enabled   = true
  }

  web_acl_rules = [
    {
      name     = "RateLimit"
      priority = 1
      action   = "block"
      statement = {
        rate_based_statement = {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.namespace}-${var.environment}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  ]

  tags = var.tags
}
