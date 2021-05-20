locals {
  db_full_names = flatten([
    for env in var.db_envs : [
      for db_name in var.db_names :
      lower(format(var.db_name_template, env, index(var.db_names, db_name) + 1, db_name))
    ]
  ])
  db_external_full_names = flatten([
    for env in var.db_allowed_external_envs : [
      for db_name in var.db_names :
      lower(format(var.db_name_template, env, index(var.db_names, db_name) + 1, db_name))
    ]
  ])
}

resource "alicloud_db_instance" "rds_instance" {
  # resource_group_id    = var.resource_group_id
  engine               = "MySQL"
  engine_version       = "8.0"
  instance_type        = var.instance_type
  instance_storage     = var.instance_storage
  vswitch_id           = var.vswitch_id
  instance_name        = var.instance_name
  tags                 = var.tags
  instance_charge_type = "Prepaid"
  period               = 1
  auto_renew           = true
  auto_renew_period    = 1
}

resource "alicloud_db_database" "database" {
  count       = length(local.db_full_names)
  instance_id = alicloud_db_instance.rds_instance.id
  name        = element(local.db_full_names, count.index)
}

resource "alicloud_rds_account" "db_xom_editor_account" {
  db_instance_id   = alicloud_db_instance.rds_instance.id
  account_name     = "xom_editor"
  account_password = var.xom_editor_password
}

resource "alicloud_rds_account" "db_xom_readonly_account" {
  db_instance_id   = alicloud_db_instance.rds_instance.id
  account_name     = "xom_readonly"
  account_password = var.xom_readonly_password
}

resource "alicloud_rds_account" "db_external_editor_account" {
  db_instance_id   = alicloud_db_instance.rds_instance.id
  account_name     = "external_editor"
  account_password = var.external_editor_password
}

resource "alicloud_rds_account" "db_external_readonly_account" {
  db_instance_id   = alicloud_db_instance.rds_instance.id
  account_name     = "external_readonly"
  account_password = var.external_readonly_password
}

resource "alicloud_db_account_privilege" "db_xom_editor_rights" {
  instance_id  = alicloud_db_instance.rds_instance.id
  account_name = alicloud_rds_account.db_xom_editor_account.name
  db_names     = alicloud_db_database.database.*.name
  privilege    = "ReadWrite"
}

resource "alicloud_db_account_privilege" "db_xom_readonly_rights" {
  instance_id  = alicloud_db_instance.rds_instance.id
  account_name = alicloud_rds_account.db_xom_readonly_account.name
  db_names     = alicloud_db_database.database.*.name
  privilege    = "ReadOnly"
}

resource "alicloud_db_account_privilege" "db_external_editor_rights" {
  instance_id  = alicloud_db_instance.rds_instance.id
  account_name = alicloud_rds_account.db_external_editor_account.name
  db_names     = matchkeys(alicloud_db_database.database.*.name, alicloud_db_database.database.*.name, local.db_external_full_names)
  privilege    = "ReadWrite"
}

resource "alicloud_db_account_privilege" "db_external_readonly_rights" {
  instance_id  = alicloud_db_instance.rds_instance.id
  account_name = alicloud_rds_account.db_external_readonly_account.name
  db_names     = matchkeys(alicloud_db_database.database.*.name, alicloud_db_database.database.*.name, local.db_external_full_names)
  privilege    = "ReadOnly"
}