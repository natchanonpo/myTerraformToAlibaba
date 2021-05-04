variable "tags" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "kafka_cidrs" {
  type = list(string)
}

variable "ecs_cidrs" {
  type = list(string)
}

variable "rds_cidrs" {
  type = list(string)
}

variable "names_prefix" {
  type = string
}

variable "ecs_names_suffix" {
  type = string
}

variable "rds_names_suffix" {
  type = string
}

variable "kafka_names_suffix" {
  type = string
}

variable "ecs_zone_ids" {
  type = string
}

variable "rds_zone_ids" {
  type = string
}

variable "kafka_zone_ids" {
  type = string
}