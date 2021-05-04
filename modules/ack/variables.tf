variable "tags" {
  type = map(any)
}

variable "log_name" {
  type = string
}

variable "k8s_name" {
  type = string
}

variable "k8s_key_name" {
  type = string
}

variable "cluster_spec" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "worker_instance_type" {
  type = string
}

variable "load_balancer_spec" {
  type = string
}

variable "pod_cidr" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "worker_disk_size" {
  type = number
}

variable "ecs_vswitch_ids" {
  type = list(string)
}

variable "cluster_addons" {
  type = list(object({
    name   = string
    config = string
  }))
}