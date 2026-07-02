variable "name" {
  type = string
}

variable "message_config" {
  type = any
}

variable "kms_config" {
  type = any
}

variable "dlq_config" {
  type = any
}

variable "tags" {
  type = map(string)
}
