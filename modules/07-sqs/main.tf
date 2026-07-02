module "sqs" {
  source  = "sourcefuse/arc-sqs/aws"
  version = "0.0.3"

  name = var.name

  message_config = var.message_config

  kms_config = var.kms_config

  dlq_config = var.dlq_config

  tags = var.tags
}
