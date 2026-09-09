variable "my_region" {
  description = "Region where the resource(s) will be managed"
  type        = string
  default     = null
}

variable "region_a" {
  type    = string
  default = null
}

variable "region_b" {
  type    = string
  default = null
}

variable "db_password" {
  type    = string
  default = null
}

variable "sso_role" {
  type    = string
  default = null
}