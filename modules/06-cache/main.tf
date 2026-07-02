module "cache" {
  source  = "sourcefuse/arc-cache/aws"
  version = "0.0.7"

  name               = var.name
  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  node_type       = var.node_type
  num_cache_nodes = var.num_cache_nodes

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_id

  automatic_failover_enabled = var.automatic_failover_enabled

  tags = var.tags
}
