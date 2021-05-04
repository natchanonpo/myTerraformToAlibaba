resource "alicloud_alikafka_instance" "kafka_instance" {
  name        = var.name
  topic_quota = var.topic_quota
  disk_type   = "1"
  disk_size   = var.disk_size
  deploy_type = "4"
  io_max      = var.io_max
  eip_max     = var.eip_max
  vswitch_id  = var.vswitch_id
}