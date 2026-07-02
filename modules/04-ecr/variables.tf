variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type = string
}

variable "scan_on_push" {
  type = bool
}

variable "lifecycle_policy" {
  type = string
}

variable "tags" {
  type = map(string)
}
