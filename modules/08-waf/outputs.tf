output "arn" {
  description = "ARN of the WAF Web ACL (REGIONAL scope for ALB)."
  value       = module.waf.arn
}
