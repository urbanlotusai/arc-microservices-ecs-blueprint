output "dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group. Consumed by 10-ecs."
  value       = module.alb.target_group_arn
}
