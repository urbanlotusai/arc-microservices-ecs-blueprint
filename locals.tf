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
  is_hipaa           = var.compliance_profile == "hipaa"
  is_pci_dss         = var.compliance_profile == "pci_dss"
  is_strict          = local.is_hipaa || local.is_pci_dss
  waf_rate_limit     = local.is_pci_dss ? 1000 : (local.is_hipaa ? 2000 : 5000)
  db_pitr_enabled    = local.is_strict
  log_retention_days = local.is_strict ? 365 : 90
}
