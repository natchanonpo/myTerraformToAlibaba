variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "resource_group_id" {
  type    = string
  default = "rg-aekzr7sprapjh4a"
}

variable "vpc_cidr" {
  type = string
}

variable "ecs_vswitch_cidrs" {
  type = list(string)
}

variable "rds_vswitch_cidrs" {
  type = list(string)
}

variable "kafka_vswitch_cidrs" {
  type = list(string)
}

variable "ecs_vswitch_zone_ids" {
  type = list(string)
}

variable "rds_vswitch_zone_ids" {
  type = list(string)
}

variable "kafka_vswitch_zone_ids" {
  type = list(string)
}

variable "rds_instance_type" {
  type = string
}

variable "rds_instance_storage" {
  type = string
}

variable "db_names" {
  type = list(string)
}

variable "db_envs" {
  type = list(string)
}

variable "kafka_disk_size" {
  type = number
}

variable "kafka_topic_quota" {
  type = number
}

variable "kafka_io_max" {
  type = number
}

variable "kafka_eip_max" {
  type = number
}

variable "k8s_cluster_spec" {
  type = string
}

variable "k8s_worker_instance_types" {
  type = string
}

variable "k8s_worker_disk_size" {
  type = string
}

variable "k8s_cluster_addons" {
  type = list(object({
    name   = string
    config = string
  }))
}