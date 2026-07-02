# =============================================================================
# 01-kms - HIPAA Compliance Profile
# =============================================================================
# HIPAA does not mandate a specific KMS deletion window. 30 days (the AWS
# maximum) is kept to give administrators the longest possible window to
# reverse an accidental key deletion before PHI encrypted under this CMK
# becomes permanently unrecoverable.
# =============================================================================

deletion_window_in_days = 30
