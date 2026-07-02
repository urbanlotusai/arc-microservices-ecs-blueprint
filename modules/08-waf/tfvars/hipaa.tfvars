# =============================================================================
# 08-waf - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - rate_limit = 2000 — a tighter per-IP request ceiling reduces the
#     exposure surface for automated scraping/enumeration attempts against
#     endpoints that may return PHI, supporting the HIPAA Security Rule's
#     access-control expectations (45 CFR 164.312(a)(1)).
# =============================================================================

rate_limit = 2000
