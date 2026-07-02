# =============================================================================
# 06-cache - PCI DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - automatic_failover_enabled = true — mandated regardless of node count,
#     supporting PCI DSS Req 12.10.1 (availability as part of an incident
#     response / business continuity plan). num_cache_nodes must stay >= 2
#     for this to take effect.
# =============================================================================

num_cache_nodes            = 2
automatic_failover_enabled = true
