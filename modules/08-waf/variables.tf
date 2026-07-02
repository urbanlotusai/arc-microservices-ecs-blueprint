variable "web_acl_name" {
  type = string
}

variable "web_acl_default_action" {
  type = string
}

variable "web_acl_scope" {
  type = string
}

variable "web_acl_visibility_config" {
  type = any
}

variable "web_acl_rules" {
  type = any
}

variable "tags" {
  type = map(string)
}
