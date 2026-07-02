module "ecr" {
  source  = "sourcefuse/arc-ecr/aws"
  version = "0.0.4"

  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  lifecycle_policy     = var.lifecycle_policy

  tags = var.tags
}
