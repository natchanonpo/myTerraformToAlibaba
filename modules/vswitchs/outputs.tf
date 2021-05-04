output "ecs_vswitch_ids" {
  value = alicloud_vswitch.ecs_vswitchs.*.id
}

output "rds_vswitch_ids" {
  value = alicloud_vswitch.rds_vswitchs.*.id
}

output "kafka_vswitch_ids" {
  value = alicloud_vswitch.kafka_vswitchs.*.id
}