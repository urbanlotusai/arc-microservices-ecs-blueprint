# ── Profile: pci_dss ──────────────────────────────────────────────────────────
# Activates the PCI DSS overlay:
#   - Aurora PITR 35 days + deletion_protection = true
#   - Redis automatic failover enabled
#   - SQS DLQ max retries = 1
#   - WAF rate limit clamped to 1000 req/IP
#   - Log retention 365 days

environment = "prod"
namespace   = "myorg"

compliance_profile = "pci_dss"

db_password            = "CHANGEME-UseSecretsManagerInProd"
db_instance_class      = "db.r6g.xlarge"
cache_num_cache_nodes  = 2
