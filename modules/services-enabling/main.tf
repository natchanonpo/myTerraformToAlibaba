data "alicloud_log_service" "open_log" {
  enable = "On"
}

data "alicloud_ack_service" "open_ack" {
  enable = "On"
  type   = "propayasgo"
}