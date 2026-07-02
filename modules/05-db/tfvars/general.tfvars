# =============================================================================
# 05-db - General Compliance Profile
# =============================================================================
# Standard 7-day backup retention with deletion protection off — keeps
# dev/test costs and friction low; storage is still always encrypted with the
# CMK from 01-kms regardless of profile.
# =============================================================================

backup_retention_period = 7
deletion_protection     = false
