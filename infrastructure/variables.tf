variable "environment" {
  type    = string
  default = "NONPROD"
}

variable "resource_group_id" {
  type    = string
  default = "rg-aekzr7sprapjh4a"
}

variable "cluster_addons" {
  type = list(object({
    name   = string
    config = string
  }))
}