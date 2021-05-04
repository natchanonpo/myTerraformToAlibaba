locals {
  db_full_names = formatlist(var.db_name_template, var.db_envs, var.db_names)
}

resource "alicloud_db_instance" "rds_instance" {
  resource_group_id = var.resource_group_id
  engine            = "MySQL"
  engine_version    = "8.0"
  instance_type     = var.instance_type
  instance_storage  = var.instance_storage
  vswitch_id        = vswitch_id
  instance_name     = var.instance_name
  tags              = var.tags
}

resource "alicloud_db_database" "database" {
  count       = length(local.db_full_names)
  instance_id = alicloud_db_instance.rds_instance.id
  name        = lower(element(local.db_full_names, count.index))
}