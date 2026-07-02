# =============================================================================
# 07-sqs - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - dlq_max_receive_count = 1 — a single failed delivery attempt moves the
#     message straight to the DLQ instead of retrying, avoiding duplicate
#     processing of PHI-bearing inter-service tasks by a flaky consumer.
# =============================================================================

dlq_max_receive_count = 1
