# =============================================================================
# 05-db - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention_period = 35 — extends the disaster-recovery window
#     for PHI stored in Aurora, supporting the HIPAA Security Rule's backup
#     requirements (45 CFR 164.308(a)(7)).
#   - deletion_protection = true — guards against accidental loss of PHI
#     records that must remain retrievable for the required retention period.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
