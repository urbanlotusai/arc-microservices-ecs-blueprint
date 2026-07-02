# =============================================================================
# 07-sqs - General Compliance Profile
# =============================================================================
# Standard queue with 3 delivery attempts before a message moves to the DLQ —
# tolerant of transient consumer failures for non-regulated workloads.
# =============================================================================

dlq_max_receive_count = 3
