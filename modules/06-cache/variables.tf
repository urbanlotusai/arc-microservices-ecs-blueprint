variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "node_type" {
  type = string
}

variable "num_cache_nodes" {
  type = number
}

variable "kms_key_id" {
  type = string
}

variable "automatic_failover_enabled" {
  type = bool
}

variable "tags" {
  type = map(string)
}
