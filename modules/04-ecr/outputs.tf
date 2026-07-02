output "repository_url" {
  description = "ECR repository URL. Push container images here before deploying."
  value       = module.ecr.repository_url
}
