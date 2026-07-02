# =============================================================================
# 08-waf - PCI DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - rate_limit = 1000 — the strictest per-IP request ceiling of the three
#     profiles, supporting PCI DSS Req 6.4.2 (deploying an automated
#     technical solution, such as a WAF, in front of public-facing web
#     applications to detect and prevent web-based attacks).
# =============================================================================

rate_limit = 1000
