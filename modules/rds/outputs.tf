output "instance_id" {
  value = alicloud_db_instance.rds_instance.id
}

output "instance_connection_port" {
  value = alicloud_db_instance.rds_instance.port
}

output "instance_connection_string" {
  value = alicloud_db_instance.rds_instance.connection_string
}

output "instance_ssl_status" {
  value = alicloud_db_instance.rds_instance.ssl_status
}

output "database_ids" {
  value = alicloud_db_instance.*.id
}