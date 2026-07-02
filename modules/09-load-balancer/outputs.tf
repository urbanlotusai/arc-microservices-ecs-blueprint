output "dns_name" {
  value = module.alb.dns_name
}

output "arn" {
  value = module.alb.arn
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}
