# =============================================================================
# Module: 04-ecr
# =============================================================================
# Provisions the ECR container registry for microservice images.
# State file: modules/04-ecr/terraform.tfstate
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
# ECR Module
# -----------------------------------------------------------------------------

module "ecr" {
  source  = "sourcefuse/arc-ecr/aws"
  version = "0.0.4"

  name                 = "${var.namespace}-${var.environment}-app"
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the last N tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_tagged_image_count
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = var.tags
}
