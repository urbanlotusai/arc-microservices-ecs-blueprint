# =============================================================================
# 06-cache - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - automatic_failover_enabled = true — mandated regardless of node count
#     to ensure availability of PHI-adjacent session/cache data (HIPAA
#     Security Rule contingency-plan requirements, 45 CFR 164.308(a)(7)).
#     num_cache_nodes must stay >= 2 for this to take effect.
# =============================================================================

num_cache_nodes            = 2
automatic_failover_enabled = true
