output "kms_key_arn" {
  description = "ARN of the KMS CMK."
  value       = module.kms.key_arn
}

output "vpc_id" {
  description = "ID of the platform VPC."
  value       = module.network.vpc_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS Fargate cluster."
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL. Push container images here before deploying."
  value       = module.ecr.repository_url
}

output "db_cluster_endpoint" {
  description = "Aurora writer endpoint."
  value       = module.db.cluster_endpoint
}

output "cache_cluster_address" {
  description = "ElastiCache Redis primary endpoint."
  value       = module.cache.cluster_address
}

output "sqs_queue_url" {
  description = "SQS task queue URL."
  value       = module.sqs.queue_url
}

output "sqs_dlq_url" {
  description = "SQS dead-letter queue URL."
  value       = module.sqs.dead_letter_queue_url
}

output "waf_arn" {
  description = "ARN of the WAF Web ACL (REGIONAL scope for ALB)."
  value       = module.waf.arn
}
