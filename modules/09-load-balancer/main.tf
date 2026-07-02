module "alb" {
  source  = "sourcefuse/arc-load-balancer/aws"
  version = "0.0.3"

  name       = var.name
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  security_group_name = var.security_group_name

  load_balancer_config = var.load_balancer_config

  # Wire WAF to ALB
  # web_acl_arn = var.web_acl_arn  # uncomment after WAF resource is fully applied

  alb_listener = var.alb_listener

  tags = var.tags
}
