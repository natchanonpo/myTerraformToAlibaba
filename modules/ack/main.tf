locals {
  full_cluster_addons = concat(var.cluster_addons, [{
    "name"   = "logtail-ds",
    "config" = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":\"${alicloud_log_project.log.name}\"}"
  }])
}

data "alicloud_log_service" "open_log" {
  enable = "On"
}

data "alicloud_ack_service" "open_ack" {
  enable = "On"
  type   = "propayasgo"
}

resource "alicloud_log_project" "log" {
  depends_on = [
    alicloud_log_service.open_log
  ]
  name        = lower(var.log_name)
  description = "log for k8s"
  tags        = var.tags
}

resource "alicloud_ecs_key_pair" "keypair" {
  key_pair_name     = var.k8s_key_name
  resource_group_id = var.resource_group_id
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  depends_on = [
    alicloud_ack_service.open_ack
  ]
  name                         = var.k8s_name
  resource_group_id            = var.resource_group_id
  version                      = "1.18.8-aliyun.1"
  cluster_spec                 = var.cluster_spec
  rds_instances                = [var.rds_instance_id]
  worker_vswitch_ids           = var.ecs_vswitch_ids
  new_nat_gateway              = true
  worker_instance_types        = [var.worker_instance_type]
  worker_instance_charge_type  = "PrePaid"
  worker_period                = 1
  worker_period_unit           = "Month"
  worker_auto_renew            = true
  worker_auto_renew_period     = 1
  worker_number                = length(var.ecs_vswitch_ids)
  worker_disk_category         = "cloud_essd"
  worker_disk_size             = var.worker_disk_size
  image_id                     = "centos_7_9_x64_20G_alibase_20201228.vhd"
  key_name                     = alicloud_ecs_key_pair.keypair.id
  pod_cidr                     = var.pod_cidr
  service_cidr                 = var.service_cidr
  install_cloud_monitor        = true
  is_enterprise_security_group = true
  load_balancer_spec           = var.load_balancer_spec
  runtime = {
    name    = "docker"
    version = "19.03.5"
  }
  dynamic "addons" {
    for_each = local.full_cluster_addons
    content {
      name   = lookup(addons.value, "name", local.full_cluster_addons)
      config = lookup(addons.value, "config", local.full_cluster_addons)
    }
  }
  tags = var.tags
}
