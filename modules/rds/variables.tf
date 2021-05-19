variable "tags" {
  type = map(any)
}

variable "resource_group_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_storage" {
  type = number
}

# variable "vswitch_id" {
#   type = string
# }

variable "db_names" {
  type = list(string)
}

variable "db_envs" {
  type = list(string)
}

variable "db_name_template" {
  type = string
}

variable "db_allowed_external_envs" {
  type = list(string)
}

# variable "xom_editor_password" {
#   type = string
# }

# variable "xom_readonly_password" {
#   type = string
# }

# variable "external_editor_password" {
#   type = string
# }

# variable "external_readonly_password" {
#   type = string
# }
