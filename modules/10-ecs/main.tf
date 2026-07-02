# =============================================================================
# Module: 10-ecs
# =============================================================================
# Provisions the ECS Fargate cluster and service definition running the
# microservice containers.
# State file: modules/10-ecs/terraform.tfstate
# Depends on: 02-network (private subnets), 03-security-group (security group),
#             05-db (Aurora endpoint), 06-cache (Redis endpoint),
#             07-sqs (queue URL), 09-load-balancer (target group ARN)
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

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/05-db/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "cache" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/06-cache/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "sqs" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/07-sqs/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/09-load-balancer/terraform.tfstate"
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
# ECS Module
# -----------------------------------------------------------------------------

module "ecs" {
  source  = "sourcefuse/arc-ecs/aws"
  version = "2.0.2"

  ecs_cluster = {
    name = "${var.namespace}-${var.environment}-ecs"
    # Container Insights for metrics and logging
    setting = [
      {
        name  = "containerInsights"
        value = "enabled"
      }
    ]
  }

  ecs_service = {
    name             = "${var.namespace}-${var.environment}-api"
    launch_type      = "FARGATE"
    desired_count    = var.desired_count
    platform_version = "LATEST"

    network_configuration = {
      subnets          = data.aws_subnets.private.ids
      security_groups  = [data.terraform_remote_state.security_group.outputs.id]
      assign_public_ip = false
    }

    load_balancer = {
      target_group_arn = data.terraform_remote_state.alb.outputs.target_group_arn
      container_name   = "api"
      container_port   = var.container_port
    }

    task_definition = {
      family                   = "${var.namespace}-${var.environment}-api"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = var.task_cpu
      memory                   = var.task_memory

      container_definitions = jsonencode([
        {
          name      = "api"
          image     = var.container_image
          essential = true
          portMappings = [
            {
              containerPort = var.container_port
              protocol      = "tcp"
            }
          ]
          environment = [
            { name = "DB_HOST", value = data.terraform_remote_state.db.outputs.cluster_endpoint },
            { name = "DB_PORT", value = tostring(var.db_port) },
            { name = "REDIS_HOST", value = data.terraform_remote_state.cache.outputs.cluster_address },
            { name = "SQS_QUEUE", value = data.terraform_remote_state.sqs.outputs.queue_url }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = "/ecs/${var.namespace}-${var.environment}-api"
              "awslogs-region"        = var.region
              "awslogs-stream-prefix" = "ecs"
            }
          }
        }
      ])
    }
  }

  tags = var.tags
}
