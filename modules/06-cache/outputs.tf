output "cluster_address" {
  description = "ElastiCache Redis primary endpoint."
  value       = module.cache.cluster_address
}
