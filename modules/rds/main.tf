locals {
  db_full_names = flatten([
    for env in var.db_envs : [
      for db_name in var.db_names :
      format(var.db_name_template, env, index(var.db_names, db_name) + 1, db_name)
    ]
  ])
}

resource "alicloud_db_instance" "rds_instance" {
  resource_group_id = var.resource_group_id
  engine            = "MySQL"
  engine_version    = "8.0"
  instance_type     = var.instance_type
  instance_storage  = var.instance_storage
  vswitch_id        = var.vswitch_id
  instance_name     = var.instance_name
  tags              = var.tags
  instance_charge_type = "PrePaid"
  period            = 1
  auto_renew        = true
  auto_renew_period = 1
}

resource "alicloud_db_database" "database" {
  count       = length(local.db_full_names)
  instance_id = alicloud_db_instance.rds_instance.id
  name        = lower(element(local.db_full_names, count.index))
}