# =============================================================================
# 07-sqs - PCI DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - dlq_max_receive_count = 1 — same rationale as HIPAA: avoids duplicate
#     processing of cardholder-data-adjacent tasks (PCI DSS Req 6.2.4 —
#     software engineering techniques to prevent common coding
#     vulnerabilities, including handling of duplicate transactions).
# =============================================================================

dlq_max_receive_count = 1
