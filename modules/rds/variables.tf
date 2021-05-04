variable "tags" {
  type = map(any)
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_storage" {
  type = string
}

variable "db_names" {
  type = list(string)
}

variable "db_envs" {
  type = list(string)
}

variable "db_name_template" {
  type = string
}