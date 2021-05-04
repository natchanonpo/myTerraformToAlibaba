variable "tags" {
  type = map(any)
}

variable "topic_quota" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "io_max" {
  type = number
}

variable "eip_max" {
  type = number
}

variable "vswitch_id" {
  type = string
}