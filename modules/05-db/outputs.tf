output "cluster_endpoint" {
  description = "Aurora writer endpoint."
  value       = module.db.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora reader endpoint."
  value       = module.db.cluster_reader_endpoint
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = module.db.cluster_arn
}
