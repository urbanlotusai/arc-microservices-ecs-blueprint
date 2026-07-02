variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_name" {
  type = string
}

variable "load_balancer_config" {
  type = any
}

variable "alb_listener" {
  type = any
}

variable "tags" {
  type = map(string)
}
