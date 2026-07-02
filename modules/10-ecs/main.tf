module "ecs" {
  source  = "sourcefuse/arc-ecs/aws"
  version = "2.0.2"

  ecs_cluster = var.ecs_cluster
  ecs_service = var.ecs_service

  tags = var.tags
}
