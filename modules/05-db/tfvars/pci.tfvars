# =============================================================================
# 05-db - PCI DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention_period = 35 — supports PCI DSS Req 12.10.1 (data
#     recovery as part of an incident response plan) for cardholder-data-
#     adjacent records.
#   - deletion_protection = true — prevents accidental loss of records needed
#     for PCI DSS Req 10 audit trails.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
