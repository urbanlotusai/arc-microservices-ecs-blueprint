# ═══════════════════════════════════════════════════════════════════════════════
# 1. KMS — root of the encryption trust chain
#    Outputs consumed by: module.db, module.cache, module.sqs
# ═══════════════════════════════════════════════════════════════════════════════
module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.11"

  alias                   = local.kms_alias
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${local.name_prefix} microservices platform"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 2. Network — VPC + public/private subnets
#    Outputs consumed by: module.security_group, module.ecs, module.db, module.cache, module.alb
# ═══════════════════════════════════════════════════════════════════════════════
module "network" {
  source  = "sourcefuse/arc-network/aws"
  version = "3.0.14"

  name        = local.name_prefix
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.vpc_cidr

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Security Groups — ECS tasks, DB, cache, ALB
#    Outputs consumed by: module.ecs, module.db, module.cache
# ═══════════════════════════════════════════════════════════════════════════════
module "security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.5"

  name        = "${local.name_prefix}-platform"
  description = "Security group for ECS tasks, Aurora, and ElastiCache"
  vpc_id      = module.network.vpc_id

  ingress_rules = [
    {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      cidr_blocks     = [var.vpc_cidr]
      description     = "ECS container port from within VPC"
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

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 4. ECR — container registry for microservice images
#    Outputs consumed by: module.ecs (task definition image URI)
# ═══════════════════════════════════════════════════════════════════════════════
module "ecr" {
  source  = "sourcefuse/arc-ecr/aws"
  version = "0.0.4"

  name                 = local.ecr_repo_name
  image_tag_mutability = "IMMUTABLE"  # prevent tag overwrites in production
  scan_on_push         = true

  # HIPAA: retain last 20 images, expire untagged after 1 day
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
        description  = "Keep only the last 20 tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["v"]
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 5. Aurora DB — persistent data store for microservices
#    Outputs consumed by: module.ecs (via environment variables at runtime)
# ═══════════════════════════════════════════════════════════════════════════════
module "db" {
  source  = "sourcefuse/arc-db/aws"
  version = "4.0.4"

  name        = local.db_name
  namespace   = var.namespace
  environment = var.environment

  engine         = var.db_engine
  engine_type    = "cluster"
  engine_version = var.db_engine_version
  license_model  = "general-public-license"
  port           = var.db_engine == "aurora-postgresql" ? 5432 : 3306

  username = var.db_username

  vpc_id = module.network.vpc_id
  db_subnet_group_data = {
    subnet_ids = data.aws_subnets.private.ids
  }

  storage_encrypted = true
  kms_key_id        = module.kms.key_arn
  instance_class    = var.db_instance_class

  # HIPAA: enable point-in-time recovery
  backup_retention_period = local.is_strict ? 35 : 7
  deletion_protection     = local.is_strict

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 6. ElastiCache Redis — session store and caching layer
#    Outputs consumed by: module.ecs (via environment variables at runtime)
# ═══════════════════════════════════════════════════════════════════════════════
module "cache" {
  source  = "sourcefuse/arc-cache/aws"
  version = "0.0.7"

  name               = local.cache_name
  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [module.security_group.id]

  node_type        = var.cache_node_type
  num_cache_nodes  = var.cache_num_cache_nodes

  # Encrypt in-transit and at-rest
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = module.kms.key_arn

  # HIPAA: enable automatic failover (requires num_cache_nodes >= 2)
  automatic_failover_enabled = local.is_strict ? true : (var.cache_num_cache_nodes > 1)

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 7. SQS — inter-service task queue with DLQ
#    Outputs consumed by: module.ecs (via IAM role + environment variables)
# ═══════════════════════════════════════════════════════════════════════════════
module "sqs" {
  source  = "sourcefuse/arc-sqs/aws"
  version = "0.0.3"

  name = local.sqs_queue_name

  message_config = {
    visibility_timeout        = 300
    retention_seconds         = 345600
    receive_wait_time_seconds = 20
  }

  kms_config = {
    key_arn      = module.kms.key_arn
    create_key   = false
  }

  dlq_config = {
    enabled           = true
    name              = "${local.sqs_queue_name}-dlq"
    max_receive_count = local.is_strict ? 1 : 3
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 8. WAF — ALB-scoped Web ACL with rate limiting
#    Outputs consumed by: module.alb (web_acl_arn)
# ═══════════════════════════════════════════════════════════════════════════════
module "waf" {
  source  = "sourcefuse/arc-waf/aws"
  version = "1.0.6"

  web_acl_name           = local.waf_name
  web_acl_default_action = "ALLOW"
  web_acl_scope          = "REGIONAL"

  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-alb-waf"
    sampled_requests_enabled   = true
  }

  web_acl_rules = [
    {
      name     = "RateLimit"
      priority = 1
      action   = "block"
      statement = {
        rate_based_statement = {
          limit              = local.is_strict ? 2000 : 5000
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  ]

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 9. Load Balancer — ALB for ECS Fargate services
#    Outputs consumed by: module.ecs (load_balancer config)
# ═══════════════════════════════════════════════════════════════════════════════
module "alb" {
  source  = "sourcefuse/arc-load-balancer/aws"
  version = "0.0.3"

  name       = local.alb_name
  vpc_id     = module.network.vpc_id
  subnet_ids = data.aws_subnets.public.ids

  security_group_name = "${local.name_prefix}-alb-sg"

  load_balancer_config = {
    internal           = false
    load_balancer_type = "application"
    idle_timeout       = 60
  }

  # Wire WAF to ALB
  # web_acl_arn = module.waf.arn  # uncomment after WAF resource is fully applied

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

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 10. ECS — Fargate cluster + service definitions for microservices
#     Consumes: module.ecr, module.db, module.cache, module.sqs, module.alb
# ═══════════════════════════════════════════════════════════════════════════════
module "ecs" {
  source  = "sourcefuse/arc-ecs/aws"
  version = "2.0.2"

  ecs_cluster = {
    name = local.cluster_name
    # Container Insights for metrics and logging
    setting = [
      {
        name  = "containerInsights"
        value = "enabled"
      }
    ]
  }

  ecs_service = {
    name             = "${local.name_prefix}-api"
    launch_type      = "FARGATE"
    desired_count    = 2
    platform_version = "LATEST"

    network_configuration = {
      subnets          = data.aws_subnets.private.ids
      security_groups  = [module.security_group.id]
      assign_public_ip = false
    }

    load_balancer = {
      target_group_arn = module.alb.target_group_arn
      container_name   = "api"
      container_port   = var.container_port
    }

    task_definition = {
      family                   = "${local.name_prefix}-api"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = "512"
      memory                   = "1024"

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
            { name = "DB_HOST",      value = module.db.cluster_endpoint },
            { name = "DB_PORT",      value = tostring(var.db_engine == "aurora-postgresql" ? 5432 : 3306) },
            { name = "REDIS_HOST",   value = module.cache.cluster_address },
            { name = "SQS_QUEUE",    value = module.sqs.queue_url }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = "/ecs/${local.name_prefix}-api"
              "awslogs-region"        = var.region
              "awslogs-stream-prefix" = "ecs"
            }
          }
        }
      ])
    }
  }

  tags = local.tags
}
