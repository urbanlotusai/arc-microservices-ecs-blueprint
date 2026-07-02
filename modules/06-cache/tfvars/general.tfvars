# =============================================================================
# 06-cache - General Compliance Profile
# =============================================================================
# num_cache_nodes = 2 with automatic_failover_enabled = true — Multi-AZ
# failover is available because the cluster has more than one node. Setting
# num_cache_nodes to 1 for cost savings would require also setting
# automatic_failover_enabled = false (a single node cannot fail over).
# Encryption in transit and at rest is always on via the CMK from 01-kms
# regardless of profile.
# =============================================================================

num_cache_nodes            = 2
automatic_failover_enabled = true
