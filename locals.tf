locals {
  # ── Naming ────────────────────────────────────────────────────────────────────
  name_prefix    = "${var.namespace}-${var.environment}"
  kms_alias      = "alias/${local.name_prefix}-microservices"
  cluster_name   = "${local.name_prefix}-ecs"
  db_name        = "${local.name_prefix}-db"
  cache_name     = "${local.name_prefix}-redis"
  sqs_queue_name = "${local.name_prefix}-tasks"
  ecr_repo_name  = "${local.name_prefix}-app"
  alb_name       = "${local.name_prefix}-alb"
  waf_name       = "${local.name_prefix}-alb-waf"

  # ── Tagging ───────────────────────────────────────────────────────────────────
  tags = {
    Environment       = var.environment
    Namespace         = var.namespace
    ManagedBy         = "terraform"
    Application       = "microservices-ecs"
    ComplianceProfile = var.compliance_profile
  }

  # ── Compliance flags ──────────────────────────────────────────────────────────
  is_strict          = var.compliance_profile == "hipaa"
  db_pitr_enabled    = local.is_strict
  log_retention_days = local.is_strict ? 365 : 90
}
